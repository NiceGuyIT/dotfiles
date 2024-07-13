function forEachWidgetInContainmentList(containmentList, callback) {
	for (var containmentIndex = 0; containmentIndex < containmentList.length; containmentIndex++) {
		var containment = containmentList[containmentIndex];

		var widgets = containment.widgets();
		for (var widgetIndex = 0; widgetIndex < widgets.length; widgetIndex++) {
			var widget = widgets[widgetIndex];
			callback(widget, containment);
			if (widget.type === "org.kde.plasma.systemtray") {
				systemtrayId = widget.readConfig("SystrayContainmentId");
				if (systemtrayId) {
					forEachWidgetInContainmentList([desktopById(systemtrayId)], callback)
				}
			}
		}
	}
}

function forEachWidget(callback) {
	forEachWidgetInContainmentList(desktops(), callback);
	forEachWidgetInContainmentList(panels(), callback);
}

function forEachWidgetByType(type, callback) {
	forEachWidget(function (widget, containment) {
		if (widget.type == type) {
			callback(widget, containment);
		}
	});
}

function logWidget(widget) {
	// print("" + widget.type + ": ");
	// print("\n")
	wj[widget.type] = {}

	var configGroups = widget.configGroups.slice(); // slice is used to clone the array
	for (var groupIndex = 0; groupIndex < configGroups.length; groupIndex++) {
		var configGroup = configGroups[groupIndex];
		// print("\t" + configGroup + ": ");
		// print("\n")
		wj[widget.type][configGroup] = {}
		widget.currentConfigGroup = [configGroup];

		for (var keyIndex = 0; keyIndex < widget.configKeys.length; keyIndex++) {
			var configKey = widget.configKeys[keyIndex];
			var configValue = widget.readConfig(configKey);
			// print("\t\t" + configKey + ": " + configValue);
			// print("\n")
			wj[widget.type][configGroup][configKey] = configValue
		}
	}
}

let wj = {}
//--- Log all widgets
forEachWidget(function (widget) {
	// print(String(widget))
	logWidget(widget);
});

print(JSON.stringify(wj, null, 2))

//--- Log only keyboardlayout widgets
// forEachWidgetByType("org.kde.plasma", function (widget) {
// 	logWidget(widget);
// });
