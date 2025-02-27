# Outputs file for SQS

# Retrieve the queue urls for the sqs queues
output "priority1_queue_url" {
    value = aws_sqs_queue.priority-1-queue.url
}

output "priority2_queue_url" {
    value = aws_sqs_queue.priority-2-queue.url
}

output "priority3_queue_url" {
    value = aws_sqs_queue.priority-3-queue.url
}