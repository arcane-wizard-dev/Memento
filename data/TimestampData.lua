local _, MEM = ...

MEM.TIMESTAMP_FORMATS = {
	{
		key = "iso",
		labelKey = "options.general.timestamp-format.option.iso",
		format = "%Y-%m-%d - %H:%M:%S"
	},
	{
		key = "month-first",
		labelKey = "options.general.timestamp-format.option.month-first",
		format = "%m/%d/%Y - %I:%M:%S %p"
	},
	{
		key = "day-first",
		labelKey = "options.general.timestamp-format.option.day-first",
		format = "%d.%m.%Y - %H:%M:%S"
	}
}

MEM.TIMESTAMP_FORMAT_BY_KEY = {}

for _, formatData in ipairs(MEM.TIMESTAMP_FORMATS) do
	MEM.TIMESTAMP_FORMAT_BY_KEY[formatData.key] = formatData
end
