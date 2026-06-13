#create VPC 
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Dev_VPC"
  }
}

#Create IGW and attach to VPC
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "Dev_IGW"
  }
}

#Create Subnet and associate with VPC
resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
    tags = {
        Name = "Dev_Subnet"
    }
}

#Create another subnet and associate with VPC
resource "aws_subnet" "dev_subnet2" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Dev_Subnet2"
  }
}

#Create route table and associate with VPC
resource "aws_route_table" "dev_route_table" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "Dev_Route_Table"
  }
}

#Associate route table with subnet 1
resource "aws_route_table_association" "dev_route_table_association" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev_route_table.id
}

#Associate route table with subnet 2
resource "aws_route_table_association" "dev_route_table_association2" {
  subnet_id      = aws_subnet.dev_subnet2.id
  route_table_id = aws_route_table.dev_route_table.id
}

#Assosiate route table with IGW
resource "aws_route" "dev_route" {
  route_table_id         = aws_route_table.dev_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Public_Subnet"
  }
}

#Create NAt gateway and associate with subnet 1
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "main-nat-gateway"
  }
}