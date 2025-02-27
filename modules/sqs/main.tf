# Creating three SQS queues based on priority

resource "aws_sqs_queue" "priority-1-queue" {
    name = var.priority1_queue_name
    message_retention_seconds = var.p1_retention
    visibility_timeout_seconds = var.p1_visibility
}

resource "aws_sqs_queue" "priority-2-queue" {
    name = var.priority2_queue_name
    message_retention_seconds = var.p2_retention
    visibility_timeout_seconds = var.p2_visibility
}

resource "aws_sqs_queue" "priority-3-queue" {
    name = var.priority3_queue_name
    message_retention_seconds = var.p3_retention
    visibility_timeout_seconds = var.p3_visibility
}