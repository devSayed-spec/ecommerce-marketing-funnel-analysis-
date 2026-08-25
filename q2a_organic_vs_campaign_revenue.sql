select
	case when campaign_id = 0 then 'Non_campaign (organic)' else 'Via Campaign' end as sumber,
	count(*) as total_transaksi,
	round(sum(gross_revenue), 2) as total_revenue,
	round(
		sum(gross_revenue) * 100.0
		/ (select sum(gross_revenue) from transactions where refund_flag = 0 )
		, 2) as pct_dari_total_revenue
from transactions 
where refund_flag = 0
group by sumber;