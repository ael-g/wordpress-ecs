# Wordpress on ECS
This project contains `terraform` files to provision a wordpress service on top of the AWS EC2 Container Service. It deploys by default in region `us-west-2` and spans two availability zones.

## Instructions
As we're using AWS `ECR` to store our docker container and that our `ECS` cluster is pulling from it, we'll need to deploy our infrastructure first and then build and push our wordpress container with `packer`

Export your AWS credentials 
```
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```
Deploy the infrastructure and get the `ECR` url (without the repo name)
```
terraform apply
export ECR_REPOSITORY=$(terraform output ecr_repository | sed 's/\/.*//')
```

Build and push our wordpress container to `ECR`
```
cd packer
packer build wordpress-packer.json
```

`ECS` agents should automatically pull our freshly pushed wordpress image and start it. After some minutes point your web-browser to the `ELB` address :
```
cd ..
terraform output elb_dns
```

## Technical 
We want our wordpress to 
 - scale easily
 - be highly available
 - be secure

#### Making the container stateless
To achieve our goal of easy scalability we want to make our wordpress container stateless, meaning that no particular data are attached to the host the container is running on. 
Wordpress text article content is stored on an external databse so we're good on this side. We'll use a `RDS` mysql instance for that.
Wordpress static content is stored at path `/var/www/html/wp-content` of the container. We'll store this on some storage space shared between hosts and mounted in the container. We'll use the `EFS` service for that (AWS' nfs as a service).
We'll use an internal route53 dns zone to associate simple names to our services:
 - db.wordpress.ael for RDS
 - nfs.wordpress.ael for EFS

We also want to put our ECS instances in an autoscaling group and put an ELB with HTTP healthcheck in front of it (cloudwatch alarms for autoscaling not implemented yet).

#### HA
To achieve HA we'll span our autoscaling group in two different availability zone.
Our RDS and NFS services are accesible to those two zones but are not HA, we should add for production deployements.

#### Security
We create a dedicated VPC for our project, associate not-too-permissive security groups to instances and put our ECS instances, DB and NFS services in a private subnet which access the internet throught a NAT (ECS instances needs to install nfs-utils at stratup and pull ECR repo). Only The ELB resides in the public subnet.

#### Implemented architecture
(NAT and internet gateway are not shown for clarity purposes)
```
us+west+2
+--------------------------------------------------------------+
|                                                              |
|           +----------------+    +----------------+           |
|           |         +-----------------+          |           |
|           |         |      |ELB |     |          |           |
|public     |         +-----------------+          | public    |
|us+west+2a +----------------+ || +----------------+ us+west+2b|
|                              ||                              |
|           +----------------+ || +----------------+           |
|           |                | || |                |           |
|           | +------------+ | || | +------------+ |           |
|           | |ECS instance| | || | |ECS instance| |           |
|           | |            +^------^+            | |           |
|           | +-----^----^-+ |    | +-----^-----^+ |           |
|private    |       |    |   |    |       |     |  | private   |
|us+west+2a +----------------+    +----------------+ us+west+2b|
|                   |    |                |     |              |
|                +--+--+ +-------------+--+--+  |              |
|                | RDS |               | EFS |  |              |
|                +-----+               +-----+  |              |
|                      +------------------------+              |
+--------------------------------------------------------------+
```
# To improve
For production environment, the following should be implemented:
 - extract logs from wordpress containers (push to elasticsearch/cloudwatch logs...) 
 - increase instance capacity (t2.micro currently)
 - increase DB size, monitor remaining space and make backups (5GB at the moment)
 - Set up CDN to serve static content (aws one, clouflare, MaxCDN...)
 - Set up Cloudwatch alarms on the ASG so we can really autoscale
 - Customize wordpress image for performance (use nginx, php fpm, tweak perf parameters...)
