#!/bin/bash

# Function to display help or usage
function show_help {
    echo "Usage: $0 [interactive] [option]"
    echo "  interactive   Run the script in interactive mode (prompts for user input)."
    echo "  option        Specific check to run (cpu, memory, disk, network, processes, logs, health, all)."
}

# Function to display the system usage report
function display_report {
    echo "=== System Usage Report ==="
    echo "Timestamp: $timestamp"
    echo "CPU Usage: $cpu_usage%"
    echo "Memory Usage: $memory_usage%"
    echo "Disk Usage: $disk_usage on /"
    echo "Network Statistics: $network_stats"
    echo "Top Processes: $top_processes"
}

# Function to display recent log entries
function display_logs {
    echo -e "\n=== Recent Log Entries ==="
    echo "$log_entries"
}

# Function to display health checks
function display_health {
    echo -e "\n=== Health Checks ==="
    echo "Apache Status: $apache_status"
    echo "MySQL Status: $mysql_status"
    echo "External Service ($external_service) Status: HTTP $external_service_status"
}

# Check if running interactively
interactive_mode=false
if [[ "$1" == "interactive" ]]; then
    interactive_mode=true
    shift
fi

# Check for specific option
option=$1

# Configuration
cpu_threshold=80.0
memory_threshold=80.0
email_recipient="sysadmin@example.com"
email_subject="Critical Alert: System Health Report"

# Function to get system metrics
function get_metrics {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
    memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    disk_usage=$(df -h / | grep -Eo '[0-9]+%')
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    network_stats=$(ss -s)
    top_processes=$(top -bn1 | head -n 12 | tail -n 7)
    log_file="/var/log/syslog"
    log_entries=$(grep -i "error\|critical" $log_file | tail -n 4)
    apache_status=$(systemctl is-active apache2)
    mysql_status=$(systemctl is-active mysql)
    external_service="example.com"
    external_service_status=$(curl -o /dev/null -s -w "%{http_code}" http://$external_service)
}

# Function to send alerts
function send_alerts {
    alert_message=""
    if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
        alert_message+="\nCPU Usage Alert: $cpu_usage% (Threshold: $cpu_threshold%)"
    fi
    if (( $(echo "$memory_usage > $memory_threshold" | bc -l) )); then
        alert_message+="\nMemory Usage Alert: $memory_usage% (Threshold: $memory_threshold%)"
    fi
    if [ -n "$alert_message" ]; then
        email_body="=== Critical Alerts ===\n\n$alert_message\n\n=== System Usage Report ===\nTimestamp: $timestamp\nCPU Usage: $cpu_usage%\nMemory Usage: $memory_usage%\nDisk Usage: $disk_usage on /\nNetwork Statistics: $network_stats\nTop Processes: $top_processes\n\n=== Recent Log Entries ===\n$log_entries\n\n=== Health Checks ===\nApache Status: $apache_status\nMySQL Status: $mysql_status\nExternal Service ($external_service) Status: HTTP $external_service_status"
        if $interactive_mode; then
            echo -e "$email_body"
        else
            echo -e "$email_body" | mail -s "$email_subject" "$email_recipient"
        fi
    fi
}

# Main Script Execution
get_metrics

if $interactive_mode; then
    echo "Select an option to view:"
    echo "1) CPU Usage"
    echo "2) Memory Usage"
    echo "3) Disk Usage"
    echo "4) Network Statistics"
    echo "5) Top Processes"
    echo "6) Recent Log Entries"
    echo "7) Health Checks"
    echo "8) All"
    read -p "Enter your choice [1-8]: " choice

    case $choice in
        1) echo "CPU Usage: $cpu_usage%";;
        2) echo "Memory Usage: $memory_usage%";;
        3) echo "Disk Usage: $disk_usage on /";;
        4) echo "Network Statistics: $network_stats";;
        5) echo "Top Processes: $top_processes";;
        6) display_logs;;
        7) display_health;;
        8) display_report
           display_logs
           display_health;;
        *) echo "Invalid option";;
    esac
else
    # Non-interactive mode: Generate the report and send alerts
    report_file="usage_report_$(date +"%Y%m%d_%H%M%S").txt"
    display_report > $report_file
    display_logs >> $report_file
    display_health >> $report_file
    send_alerts
    echo "Report saved to: $report_file"
fi
