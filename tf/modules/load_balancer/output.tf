output "service_host" {
    value = aws_lb.backend_lb.dns_name
}

output "landing_dns" {
    value = aws_lb.landing_lb.dns_name
}

output "dashboard_dns" {
    value = aws_lb.dashboard_lb.dns_name
}

output "admin_dns" {
    value = aws_lb.admin_lb.dns_name
}

output "backend_lb_sg_id" {
    value = aws_security_group.backend_lb_sg.id
}

output "landing_lb_sg_id" {
    value = aws_security_group.landing_lb_sg.id
}

output "dashboard_lb_sg_id" {
    value = aws_security_group.dashboard_lb_sg.id
}

output "admin_lb_sg_id" {
    value = aws_security_group.admin_lb_sg.id
}

output "backend_tg" {
    value = aws_lb_target_group.backend_tg
}

output "landing_tg_arn" {
    value = aws_lb_target_group.landing_tg.arn
}

output "dashboard_tg_arn" {
    value = aws_lb_target_group.dashboard_tg.arn
}

output "admin_tg_arn" {
    value = aws_lb_target_group.admin_tg.arn
}