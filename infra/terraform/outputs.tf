output "public_ip" {
  description = "새 EC2의 공인 IPv4. 중지·시작하면 바뀔 수 있습니다."
  value       = aws_instance.web.public_ip
}

output "web_url" {
  description = "과제 A 방식 외부 접속 검증 주소. 출력만으로 서비스 성공이 검증되지는 않습니다."
  value       = "http://${aws_instance.web.public_ip}/"
}

output "ssh_command" {
  description = "<LOCAL_PRIVATE_KEY_PATH>를 본인 PC의 개인키 경로로 바꾸세요."
  value       = "ssh -i <LOCAL_PRIVATE_KEY_PATH> ec2-user@${aws_instance.web.public_ip}"
}

output "resource_ids" {
  description = "이 Terraform 구성이 생성한 자원의 점검·정리용 ID입니다."
  value = {
    vpc              = aws_vpc.lab.id
    subnet           = aws_subnet.public.id
    internet_gateway = aws_internet_gateway.lab.id
    route_table      = aws_route_table.public.id
    security_group   = aws_security_group.web.id
    instance         = aws_instance.web.id
    root_volume      = aws_instance.web.root_block_device[0].volume_id
  }
}
