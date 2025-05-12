from flask import Flask, request, jsonify, send_file
from pymongo import MongoClient
from datetime import datetime
import os
from collections import defaultdict
from flask import render_template_string, request
from datetime import datetime, timedelta

app = Flask(__name__)


#APP_IP = os.getenv("APP_IP")
#APP_PORT = os.getenv("APP_PORT")
#MONGO_URL = os.getenv("MONGO_URL")
APP_IP = "192.168.31.89"
APP_PORT = "5000"
MONGO_URL = "mongodb://localhost:27017/"

client = MongoClient(MONGO_URL)
db = client.logsdb
collection = db.logs

#Endpoint to download the logs
@app.route("/upload", methods=["POST"])
def upload_log():
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No file provided"}), 400

    try:
        content = file.read().decode("utf-8").strip()
        parts = content.split()
        if len(parts) != 4:
            return jsonify({"error": "Invalid log format"}), 400

        timestamp_str, hostname, local_ip, peer_ip = parts

        log_entry = {
            "timestamp": timestamp_str,
            "hostname": hostname,
            "local_ip": local_ip,
            "peer_ip": peer_ip,
            "received_at": datetime.utcnow()
        }
        collection.insert_one(log_entry)

        return jsonify({"status": "log stored"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

#All logs like list
@app.route("/logs", methods=["GET"])
def get_logs():
    logs = list(collection.find({}, {"_id": 0}))

    if not logs:
        return render_template_string(base_template, content="<p>No logs available.</p>")

    headers = logs[0].keys()
    table_html = "<h2>All Logs</h2><div class='table-responsive'><table class='table table-striped table-bordered'><thead><tr>"
    for header in headers:
        table_html += f"<th>{header}</th>"
    table_html += "</tr></thead><tbody>"

    for log in logs:
        table_html += "<tr>"
        for header in headers:
            table_html += f"<td>{log.get(header, '')}</td>"
        table_html += "</tr>"

    table_html += "</tbody></table></div>"

    return render_template_string(base_template, content=table_html)


#Stats by VM's
@app.route("/stats", methods=["GET"])
def stats():
    result = defaultdict(lambda: defaultdict(int))

    logs = collection.find()
    for log in logs:
        hostname = log.get("hostname")
        peer_ip = log.get("peer_ip")
        if hostname and peer_ip:
            result[hostname][peer_ip] += 1

    output = {host: dict(peers) for host, peers in result.items()}

    # Table generation
    table_html = "<h2>Log Stats by Host</h2><table class='table table-bordered w-auto'><thead><tr><th>Hostname</th><th>Peer IP</th><th>Count</th></tr></thead><tbody>"
    for host, peers in output.items():
        for peer, count in peers.items():
            table_html += f"<tr><td>{host}</td><td>{peer}</td><td>{count}</td></tr>"
    table_html += "</tbody></table>"

    return render_template_string(base_template, content=table_html)


#Latest log
@app.route("/latest")
def get_latest():
    latest_log = collection.find_one(sort=[("received_at", -1)], projection={"_id": 0})
    if not latest_log:
        return render_template_string(base_template, content="<p>No logs found.</p>")

    table_rows = "".join(f"<tr><th>{key}</th><td>{value}</td></tr>" for key, value in latest_log.items())
    content = f"""
    <h2>Latest Log Entry</h2>
    <table class="table table-bordered w-auto">
        {table_rows}
    </table>
    """
    return render_template_string(base_template, content=content)


#Upload debug log
@app.route("/debug-log", methods=["POST"])
def debug_log():
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No debug script"}), 400

    filename = request.form.get("filename", file.filename)
    path = os.path.join("debug_logs", filename)
    os.makedirs("debug_logs", exist_ok=True)
    file.save(path)
    return jsonify({"status": "debug log saved", "filename": filename})

#Debug log output
@app.route("/debug-view")
def debug_view():
    folder = "debug_logs"
    if not os.path.exists(folder):
        return render_template_string(base_template, content="<p><strong>No debug logs found (folder missing).</strong></p>")

    entries_html = """
    <h2>Debug Logs</h2>
    <div class='accordion' id='debugAccordion'>
    """

    for i, fname in enumerate(sorted(os.listdir(folder))):
        file_path = os.path.join(folder, fname)
        try:
            with open(file_path, "r") as f:
                content = f.read()
        except Exception as e:
            content = f"[Error reading file: {e}]"

        entries_html += f"""
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading{i}">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse{i}" aria-expanded="false" aria-controls="collapse{i}">
                    {fname}
                </button>
            </h2>
            <div id="collapse{i}" class="accordion-collapse collapse" aria-labelledby="heading{i}" data-bs-parent="#debugAccordion">
                <div class="accordion-body">
                    <pre style='white-space: pre-wrap; word-wrap: break-word;'>{content}</pre>
                </div>
            </div>
        </div>
        """

    entries_html += "</div>"

    return render_template_string(base_template + """
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
        }
        .accordion-button {
            background-color: #007bff;
            color: white;
        }
        .accordion-button:focus {
            box-shadow: none;
        }
        .accordion-item {
            margin-bottom: 10px;
        }
        pre {
            background-color: #343a40;
            color: #ffffff;
            padding: 15px;
            border-radius: 5px;
        }
    </style>
    """ + entries_html)

#Graphs
@app.route("/graph")
def graph():
    start = request.args.get("start")
    end = request.args.get("end")

    try:
        start_dt = datetime.strptime(start, "%Y-%m-%dT%H:%M") if start else datetime.utcnow() - timedelta(days=7)
        end_dt = datetime.strptime(end, "%Y-%m-%dT%H:%M") if end else datetime.utcnow()
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DDTHH:MM"}), 400

    pipeline_hosts = [
        {"$match": {"received_at": {"$gte": start_dt, "$lte": end_dt}}},
        {"$group": {
            "_id": {
                "minute": {"$dateToString": {"format": "%Y-%m-%d %H:%M", "date": "$received_at"}},
                "host": "$hostname"
            }
        }},
        {"$group": {"_id": "$_id.minute", "unique_hosts": {"$sum": 1}}},
        {"$sort": {"_id": 1}}
    ]
    data_hosts = list(collection.aggregate(pipeline_hosts))
    labels = [item["_id"] for item in data_hosts]
    values = [item["unique_hosts"] for item in data_hosts]

    pipeline_by_hour = [
        {"$match": {"received_at": {"$gte": start_dt, "$lte": end_dt}}},
        {"$group": {
            "_id": {"$dateToString": {"format": "%Y-%m-%d %H:00", "date": "$received_at"}},
            "count": {"$sum": 1}
        }},
        {"$sort": {"_id": 1}}
    ]
    data_by_hour = list(collection.aggregate(pipeline_by_hour))
    hour_labels = [item["_id"] for item in data_by_hour]
    hour_counts = [item["count"] for item in data_by_hour]

    pipeline_by_host = [
        {"$match": {"received_at": {"$gte": start_dt, "$lte": end_dt}}},
        {"$group": {
            "_id": "$hostname",
            "count": {"$sum": 1}
        }},
        {"$sort": {"_id": 1}}
    ]
    data_by_host = list(collection.aggregate(pipeline_by_host))
    host_labels = [item["_id"] for item in data_by_host]
    host_counts = [item["count"] for item in data_by_host]

    return render_template_string(base_template + """
    <h2>Log Graphs ({{ start_dt.strftime('%Y-%m-%d') }} -- {{ end_dt.strftime('%Y-%m-%d') }})</h2>
    <form method="get" class="mb-4">
        From: <input type="datetime-local" name="start" value="{{ request.args.get('start', '') }}">
        To: <input type="datetime-local" name="end" value="{{ request.args.get('end', '') }}">
        <button type="submit" class="btn btn-sm btn-primary">Filter</button>
    </form>

    <h5>Unique Hosts by Minute</h5>
    <div class="d-flex justify-content-center mb-5">
        <div style="width: 900px; height: 600px;">
            <canvas id="chart1" style="width: 100%; height: 100%;"></canvas>
        </div>
    </div>

    <h5 class="mt-5">Logs Count by Hour</h5>
    <div class="d-flex justify-content-center mb-5">
        <div style="width: 900px; height: 600px;">
            <canvas id="chart2" style="width: 100%; height: 100%;"></canvas>
        </div>
    </div>

    <h5 class="mt-5">6Logs Count by Host</h5>
    <div class="d-flex justify-content-center mb-5">
        <div style="width: 900px; height: 600px;">
            <canvas id="chart3" style="width: 100%; height: 100%;"></canvas>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        new Chart(document.getElementById('chart1'), {
            type: 'line',
            data: {
                labels: {{ labels|tojson }},
                datasets: [{
                    label: 'Unique machines',
                    data: {{ values|tojson }},
                    borderColor: 'rgb(75, 192, 192)',
                    fill: false,
                    tension: 0.3
                }]
            }
        });

        new Chart(document.getElementById('chart2'), {
            type: 'bar',
            data: {
                labels: {{ hour_labels|tojson }},
                datasets: [{
                    label: 'Logs per hour',
                    data: {{ hour_counts|tojson }},
                    backgroundColor: 'rgba(54, 162, 235, 0.6)'
                }]
            }
        });

        new Chart(document.getElementById('chart3'), {
            type: 'bar',
            data: {
                labels: {{ host_labels|tojson }},
                datasets: [{
                    label: 'Logs per host',
                    data: {{ host_counts|tojson }},
                    backgroundColor: 'rgba(255, 99, 132, 0.6)'
                }]
            }
        });
    </script>
    """, labels=labels, values=values,
         hour_labels=hour_labels, hour_counts=hour_counts,
         host_labels=host_labels, host_counts=host_counts,
         start_dt=start_dt, end_dt=end_dt, request=request)


@app.route("/")
def dashboard():
    return render_template_string("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Main page</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="p-4">
        <div class="container">
            <h1 class="mb-4">Log Monitoring Dashboard</h1>
            <nav class="mb-4">
                <a href="/logs" class="btn btn-primary btn-sm">/logs</a>
                <a href="/stats" class="btn btn-secondary btn-sm">/stats</a>
                <a href="/latest" class="btn btn-success btn-sm">/latest</a>
                <a href="/debug-view" class="btn btn-warning btn-sm">/debug-view</a>
                <a href="/graph" class="btn btn-info btn-sm">/graph</a>
            </nav>
            <p>Click a button to view raw JSON or charts in separate tabs.</p>
        </div>
    </body>
    </html>
    """)


base_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Flask Log Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="p-4">
    <div class="container">
        <h1 class="mb-4">Log Dashboard</h1>
        <nav class="mb-4">
            <a href="/" class="btn btn-outline-dark btn-sm">Dashboard</a>
            <a href="/logs" class="btn btn-outline-primary btn-sm">/logs</a>
            <a href="/stats" class="btn btn-outline-secondary btn-sm">/stats</a>
            <a href="/latest" class="btn btn-outline-success btn-sm">/latest</a>
            <a href="/debug-view" class="btn btn-outline-warning btn-sm">/debug-view</a>
            <a href="/graph" class="btn btn-outline-info btn-sm">/graph</a>
        </nav>
        <div>
            {{ content|safe }}
        </div>
    </div>
</body>
</html>
"""


if __name__ == "__main__":
    app.run(debug=False, host=APP_IP, port=int(APP_PORT))

