import pandas as pd
customers = pd.read_csv('customers.csv')
transactions = pd.read_csv('transactions.csv')
events = pd.read_csv('events.csv')

customers['signup_date'] = pd.to_datetime(customers['signup_date'])
transactions['timestamp'] = pd.to_datetime(transactions['timestamp'])
events['timestamp'] = pd.to_datetime(events['timestamp'])

tx_check = transactions.merge(
    customers[['customer_id', 'signup_date', 'acquisition_channel']],
    on='customer_id', how='left'
)

anomaly = tx_check[tx_check['timestamp'] < tx_check['signup_date']].copy()
anomaly['gap_days'] = (anomaly['signup_date'] - anomaly['timestamp']).dt.days

print("Statistik gap hari (transaksi terjadi X hari sebelum signup)")
print(anomaly['gap_days'].describe())
print()
print("Distribusi gap (dalam beberapa rentang):")
print(f"0-7 hari: {((anomaly['gap_days']>=0)&(anomaly['gap_days']<=7)).sum()}")
print(f"8-30 hari: {((anomaly['gap_days']>7)&(anomaly['gap_days']<=30)).sum()}")
print(f"31-365 hari: {((anomaly['gap_days']>30)&(anomaly['gap_days']<=365)).sum()}")
print(f">365 hari: {(anomaly['gap_days']>365).sum()}")

print("\nAnomali per tahun transaksi")
anomaly['tx_year'] = anomaly['timestamp'].dt.year
tx_check['tx_year'] = tx_check['timestamp'].dt.year
total_per_year = tx_check.groupby('tx_year').size()
anomaly_per_year = anomaly.groupby('tx_year').size()
pct = (anomaly_per_year / total_per_year * 100).round(1)
print(pd.DataFrame({'total': total_per_year, 'anomali': anomaly_per_year, 'persen': pct}))

print("\nAnomali per acquisition_channel")
total_per_channel = tx_check.groupby('acquisition_channel').size()
anomaly_per_channel = anomaly.groupby('acquisition_channel').size()
pct_channel = (anomaly_per_channel / total_per_channel * 100).round(1)
print(pd.DataFrame({'total': total_per_channel, 'anomali': anomaly_per_channel, 'persen': pct_channel}))