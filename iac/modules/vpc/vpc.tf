resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-vpc"
      Environment = var.environment
    }
  )
}

resource "aws_subnet" "public" {
  for_each                = { for i, az in var.availability_zones : i => az }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-public-subnet-${each.key + 1}"
      Environment = var.environment
      Type        = "Public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each          = { for i, az in var.availability_zones : i => az }
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[each.key]
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-private-subnet-${each.key + 1}"
      Environment = var.environment
      Type        = "Private"
    }
  )
}
