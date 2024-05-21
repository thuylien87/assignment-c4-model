workspace extends ../model.dsl {
    model {
        # Deployment
        prodEnvironment = deploymentEnvironment "Production" {
            deploymentNode "AWS EKS" {
                tags "Amazon Web Services - Elastic Kubernetes Service"                

                deploymentNode "ap-southeast-1" {
                    tags "Amazon Web Services - Region"

                    appLoadBalancer = infrastructureNode "Application Load Balancer" {
                        tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                    }

                    cloudFront = infrastructureNode "CloudFront" {
                        tags "Amazon Web Services - CloudFront"
                    }

                    deploymentNode "S3" {
                        tags "Amazon Web Services - S3"

                        frontStoreAppInstance = containerInstance frontStoreApp
                    }

                    deploymentNode "prod-vpc-a" {
                        tags "Amazon Web Services - VPC"

                        deploymentNode "eks-cluster" {
                            tags "Amazon Web Services - Elastic Kubernetes Service"

                            deploymentNode "ec2-a" {
                                tags "Amazon Web Services - EC2 Instance"

                                containerInstance backOfficeApp
                                containerInstance searchApi
                                containerInstance adminWebApi
                                containerInstance publicWebApi
                            }                                 
                        }
                    }

                    deploymentNode "prod-vpc-b" {
                        tags "Amazon Web Services - VPC"

                        deploymentNode "eks-cluster" {
                            tags "Amazon Web Services - Elastic Kubernetes Service"

                            deploymentNode "ec2-b" {
                                tags "Amazon Web Services - EC2 Instance"

                                deploymentNode "PostgreSQL RDS" {
                                    tags "Amazon Web Services - RDS"
                                    
                                    containerInstance bookstoreDatabase
                                }

                                deploymentNode "AWS OpenSearch " {
                                    tags "Amazon Web Services - OpenSearch Service"

                                    containerInstance searchDatabase
                                }

                                containerInstance bookEventSystem
                                containerInstance bookSearchEventConsumer
                            }                                 
                        }
                    }

                }    

                route53 = infrastructureNode "Route 53" {
                    tags "Amazon Web Services - Route 53"
                }                
            }
            route53 -> appLoadBalancer
            appLoadBalancer -> cloudFront "Forwards requests to" "[HTTPS]"
            cloudFront -> frontStoreAppInstance "Forwards requests to" "[HTTPS]"
        }

        developer = person "Developer" "Internal bookstore platform developer" "User"
        deployWorkflow = softwareSystem "CI/CD Workflow" "Workflow CI/CD for deploying system using AWS Services" "Target System" {
            repository = container "Code Repository" "" "Github"

            pipeline = container "CodePipeline" {
                tags "Amazon Web Services - CodePipeline" "Dynamic Element"
            }
            codeBuild = container "CodeBuild" "" {
                tags "Amazon Web Services - CodeBuild" "Dynamic Element"
            }
            amazonECR = container "Amazon ECR" {
                tags "Amazon Web Services - EC2 Container Registry" "Dynamic Element"
            }
            amazonEKS = container "Amazon EKS" {
                tags "Amazon Web Services - Elastic Kubernetes Service" "Dynamic Element"
            }
        }
        developer -> repository
        repository -> pipeline
        pipeline -> codeBuild
        codeBuild -> amazonECR
        codeBuild -> pipeline
        pipeline -> amazonEKS
    }

    views {
        # deployment <software-system> <environment> <key> <description>
        deployment bookstoreSystem prodEnvironment "Dep-001-PROD" "Cloud Architecture for Bookstore Platform using AWS Services" {
            include *
            autoLayout lr
        }
        #dynamic <container> <name> <description>
        dynamic deployWorkflow "Dynamic-001-WF" "Bookstore platform deployment workflow" {
            developer -> repository "Commit, and push changes"
            repository -> pipeline "Trigger pipeline to build in AWS"
            pipeline -> codeBuild "Download source code, and start build process"
            codeBuild -> amazonECR "Pushes the container image with unique tag"
            pipeline -> amazonEKS "Deploys image"
            autoLayout lr
        }

        theme "https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json"

        styles {
            element "Dynamic Element" {
                background #ffffff
            }
        }
    }
}