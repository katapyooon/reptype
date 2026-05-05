resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "reptype_vpc"
  }
}

resource "aws_subnet" "public" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}
