local _, MEM = ...

MEM.UIConfig.Timestamp = {
	formats = {
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
	},
	formatsByKey = {}
}

local TimestampConfig = MEM.UIConfig.Timestamp

for _, formatData in ipairs(TimestampConfig.formats) do
	TimestampConfig.formatsByKey[formatData.key] = formatData
end
