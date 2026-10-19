variable "aws_account_id" {
  description = "실습 AWS 계정의 12자리 ID. 다른 계정에 잘못 적용하지 않도록 제한합니다."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS 계정 ID는 숫자 12자리여야 합니다."
  }
}

variable "ssh_cidr" {
  description = "SSH를 허용할 학습자 공인 IPv4 한 개. 예: 198.51.100.10/32."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.ssh_cidr, 0)) &&
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.ssh_cidr))
    )
    error_message = "SSH 소스는 올바른 IPv4 주소 하나의 /32여야 합니다. 전체 공개와 IPv6는 허용하지 않습니다."
  }
}

variable "key_pair_name" {
  description = "서울 리전에 이미 존재하는 EC2 키 페어 이름. 개인키 파일이나 키 원문이 아닙니다."
  type        = string

  validation {
    condition = (
      length(trimspace(var.key_pair_name)) > 0 &&
      !startswith(var.key_pair_name, "REPLACE_")
    )
    error_message = "실제로 보유한 기존 EC2 키 페어 이름을 입력하세요. 예제 자리표시자는 사용할 수 없습니다."
  }
}

variable "name_prefix" {
  description = "새 자원의 이름 접두사. 이름만 같다고 기존 자원에 연결되는 것은 아닙니다."
  type        = string
  default     = "b3-1-iac"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,29}$", var.name_prefix))
    error_message = "이름은 소문자로 시작하고 소문자·숫자·하이픈으로 3~30자여야 합니다."
  }
}
