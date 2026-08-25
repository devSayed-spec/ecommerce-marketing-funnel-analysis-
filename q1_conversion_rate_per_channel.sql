select  
	traffic_source,
	count(case when event_type = 'view' then 1 end) as total_view,
	count(case when event_type = 'add_to_cart' then 1 end) as total_add_to_cart,
	count(case when event_type = 'purchase' then 1 end) as total_purchase,
	round(
			count(case when event_type = 'purchase' then 1 end) * 100.0 
			/nullif(count(case when event_type = 'view' then 1 end), 0), 
		2) as conversion_rate_view_to_purchase_pct
from events 
group by traffic_source 
order by conversion_rate_view_to_purchase_pct desc;