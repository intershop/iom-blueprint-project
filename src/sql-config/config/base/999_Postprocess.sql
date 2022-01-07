UPDATE oms."PlatformConfigDO" SET "lastConfigDate" = now();
select oms.clear_cache_request('bakery-cache-config');