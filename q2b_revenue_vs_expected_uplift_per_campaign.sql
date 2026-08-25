with campaign_agg as (
	select
		c.campaign_id,
		c.channel,
		c.objective,
		c.target_segment,
		c.expected_uplift,
		count(t.transaction_id) as total_transaksi,
		round(sum(t.gross_revenue), 2) as total_revenue,
		round(avg(t.gross_revenue), 2) as avg_revenue_per_transaksi
	from campaigns c
	left join transactions t 
		on c.campaign_id = t.campaign_id
		and t.refund_flag = 0
	where c.campaign_id != 0
	group by c.campaign_id, c.channel, c.objective, c.target_segment, c.expected_uplift
)
select 
	a.campaign_id,
	a.channel,
	a.objective,
	a.target_segment,
	a.expected_uplift,
	a.total_transaksi,
	a.total_revenue,
	a.avg_revenue_per_transaksi,
	(select count(*) from campaign_agg b where b.total_revenue > a.total_revenue) + 1 as rank_revenue,
	(select count(*) from campaign_agg b where b.expected_uplift > a.expected_uplift) + 1 as rank_expected_uplift
from campaign_agg a
order by a.total_revenue desc;