
WorkerScript.onMessage =  function(message) {
	var list = message.inData.nodes;
	var retList = [];
	for(var i in list) {
        
		if(message.searchTerm == "" ||
			list[i].host && list[i].host.match(new RegExp(message.searchTerm,'i')) || 
			list[i].name && list[i].name.match(new RegExp(message.searchTerm,'i')) ) {
// 			console.log(JSON.stringify(list[i]));
			retList.push(list[i]);
		}
	}
	 var results =retList;
	 WorkerScript.sendMessage({reply: results, userdata:message.inData});
}

 
 
