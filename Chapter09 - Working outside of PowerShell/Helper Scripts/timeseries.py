import argparse
import pandas as pd
import matplotlib.pyplot as plt

# Define command line arguments
parser = argparse.ArgumentParser(description='Creates and saves a time series chart')
parser.add_argument('output', type=str, help='The name of the output file')
parser.add_argument('title', type=str, help='The title of the chart')
parser.add_argument('json_data', type=str, help='The time series JSON to populate the chart with.')
args = parser.parse_args()

# plot time series chart
series = pd.read_json(args.json_data)
plt.plot_date(series['Timestamp'], series['Value'], linestyle ='solid')
plt.title(args.title)
plt.xlabel('Time')
plt.ylabel('counter')
plt.grid(True)

# save the chart locally
plt.savefig(args.output)
print('File saved to : ' + args.output)