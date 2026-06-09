resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-nat-eip"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-nat-gateway"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}
