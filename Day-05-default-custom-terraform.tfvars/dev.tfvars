ami_id  =   "ami-00e801948462f718a"
instance_type = "t2.micro" 
name = "MyEC2Instance"


#terraform apply  -auto-approve -var-file="dev.tfvars"
#default name is terrafrom.tfvars, if we have multiple env we can create different tfvars file and specify the file name in command line. If we have only one tfvars file then we can skip the -var-file argument as terraform will automatically pick up the default tfvars file.
#example dev.tfvars, prod.tfvars, staging.tfvars etc. We can also have multiple tfvars files and specify them in command line as well. terraform apply -auto-approve -var-file="dev.tfvars" -var-file="prod.tfvars" etc. The variables defined in the tfvars file will override the default values defined in the variables.tf file. If we have multiple tfvars files then the variables defined in the last tfvars file will override the variables defined in the previous tfvars files.