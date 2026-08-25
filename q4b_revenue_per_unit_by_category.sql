select 
	p.category,
	sum(t.quantity) as total_unit_terjual,
	round(sum(t.gross_revenue), 2) as total_revenue,
	round(sum(t.gross_revenue) / sum(t.quantity), 2) as revenue_per_unit
from transactions t
join products p
	on t.product_id = p.product_id
where t.refund_flag = 0
group by p.category
order by revenue_per_unit asc;