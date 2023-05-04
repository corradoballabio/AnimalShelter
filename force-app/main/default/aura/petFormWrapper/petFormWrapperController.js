({
	closeTab: function(component, event) {
		let workspaceAPI = component.find("workspaceAPI");

		workspaceAPI.getFocusedTabInfo().then(response => {
			let focusedTabId = response.tabId;
			workspaceAPI.closeTab({tabId: focusedTabId});
		}).catch(function(error) {
			console.log(error);
		});
	},
})
