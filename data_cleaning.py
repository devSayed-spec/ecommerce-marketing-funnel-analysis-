import pandas as pd 
import os

campaigns =pd.read_csv('campaigns.csv')
customers = pd.read_csv('customers.csv')
events = pd.read_csv('events.csv')
products = pd.read_csv('products.csv')
products['launch_date'] = pd.to_datetime(products['launch_date'], format='%Y-%m-%d')
transactions = pd.read_csv('transactions.csv')

print("Data berhasil dimuat")
print(f"campaigns: {campaigns.shape}")
print(f"customers: {customers.shape}")
print(f"events: {events.shape}")
print(f"products: {products.shape}")
print(f"transactions: {transactions.shape}")

print("\nSebelum cleaning, traffic_source unique values:")
print(events['traffic_source'].unique())

events['traffic_source'] = events['traffic_source'].str.title()

print("\nSetelah cleaning")
print(events['traffic_source'].unique())

events['product_id'] = events['product_id'].fillna(-1)
events['device_type'] = events['device_type'].fillna('Unknown')

print("\nMissing values events.csv setelah cleaning:")
print(events.isna().sum()[events.isna().sum() > 0])

transactions['is_failed_transaction'] = (
    transactions['product_id'].isna() | transactions['gross_revenue'].isna()
).astype(int)

transactions['product_id'] = transactions['product_id'].fillna(-1)
transactions['gross_revenue'] = transactions['gross_revenue'].fillna(0)

print("\njumlah transaksi gagal/ corrupt yang ditandai:")
print(transactions['is_failed_transaction'].sum())

customers['signup_date'] = pd.to_datetime(customers['signup_date'])
events['timestamp'] = pd.to_datetime(events['timestamp'])
transactions['timestamp'] = pd.to_datetime(transactions['timestamp'])

events_check = events.merge(customers[['customer_id', 'signup_date']], on='customer_id', how='left')
tx_check = transactions.merge(customers[['customer_id', 'signup_date']], on='customer_id', how='left')

events['is_before_signup'] = (events_check['timestamp'] < events_check['signup_date']).astype(int)
transactions['is_before_signup'] = (tx_check['timestamp'] < tx_check['signup_date']).astype(int)

print("\nanomali timestamp (event/transaksi sebelum signup_date):")
print(f"events: {events['is_before_signup'].sum()} dari {len(events)} baris" 
      f" ({events['is_before_signup'].mean() * 100:.1f}%)")
print(f"transactions: {transactions['is_before_signup'].sum()} dari {len(transactions)} baris"
      f"({transactions['is_before_signup'].mean() * 100:.1f}%)")

os.makedirs('clean', exist_ok=True)

campaigns.to_csv('clean/campaigns.csv', index=False)
customers.to_csv('clean/customers.csv', index=False)
events.to_csv('clean/events.csv', index=False)
products.to_csv('clean/products.csv', index=False)
transactions.to_csv('clean/transactions.csv', index=False)

print("\nData berhasil dibersihkan dan disimpan di folder 'clean'")