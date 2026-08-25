with kategori_agg as (
	select
		p.category,
		count(t.transaction_id) as total_transaksi,
		sum(t.quantity) as total_unit_terjual,
		round(sum(t.gross_revenue), 2) as total_revenue,
		round(avg(t.gross_revenue), 2) as avg_revenue_per_transaksi
	from transactions t 
	join products p 
		on t.product_id = p.product_id
	where t.refund_flag = 0
	group by p.category
),
total_semua as (
	select 
		sum(total_revenue) as grand_total_revenue
	from kategori_agg
)
select 
	k.category,
	k.total_transaksi,
	k.total_unit_terjual,
	k.total_revenue,
	k.avg_revenue_per_transaksi,
	round(k.total_revenue * 100.0 / t.grand_total_revenue, 2) as pct_kontribusi_revenue,
	(select count(*) from kategori_agg k2 where k2.total_unit_terjual > k.total_unit_terjual) + 1 as rank_volume,
	(select count(*) from kategori_agg k2 where k2.total_revenue > k.total_revenue) + 1 as rank_revenue
from kategori_agg k, total_semua t
order by k.total_revenue desc;