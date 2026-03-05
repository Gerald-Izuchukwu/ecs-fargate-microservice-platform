resource "aws_vpc" "ecs_fargate" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.ecs_fargate.id
  cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index) #cidrsubnet(base_cidr, newbits, subnet_number)
  availability_zone = "${var.aws_region}${element(["a", "b"], count.index)}" // this will work but is not dynamic or scalable, what if we have 3 subnets, we will have to then add "c" to the list and so on, this is not ideal
  # availability_zone =  element(data.aws_availability_zones.available.names, count.index) // this is the best option because it is dynamic and scalable, it will return the availability zones in the region and we can have as many subnets as we want without having to worry about the availability zones
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.ecs_fargate.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
  availability_zone = "${var.aws_region}${element(["a", "b"], count.index)}"

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_fargate.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.ecs_fargate.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.ecs_fargate.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}


resource "aws_route_table_association" "private_subnet" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}




# # Notes
# So basically, when you create a resource and you give it a count and set the count to a number eg 2
# it creates the number of resource ie 2 and names them internally like Resource[0] and Resource[1]
# Now when you want to reference these resources, all you have to do is use count.index
# so the first copy of the resource ie Resource[0] will have count.index = 0 and the second copy of the resource ie Resource[1] will have count.index = 1
# so if you want to reference the first copy of the resource, you can use Resource[count.index] and it will return Resource[0] and if you want to reference the second copy of the resource, you can use Resource[count.index] and it will return Resource[1]
# Also keep in mind that count.index return a number eg 0 or 1 or 2 but that number reperesents that copy of that resource
# so  """ availability_zone = "${var.aws_region}${element(["a", "b"], count.index)}" """ would losely translate to 
# availability_zone = "${var.aws_region}${element(["a", "b"], 0)}" and this 0 represents the first copy of the resource