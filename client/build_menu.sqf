PURCHASE_MENU_OPEN       = false;
PURCHASE_MENU_CART_ITEMS = [];

disableSerialization; 
private _display = findDisplay 46 createDisplay "RscDisplayEmpty"; 

ASSET_LISTBOX_POS = [0.25, 0, 0.5, 0.25];

ASSET_LISTBOX = _display ctrlCreate ["RscControlsGroupNoScrollbars", (count PURCHASE_MENU_ITEMS) + 1];
ASSET_LISTBOX ctrlSetPosition ASSET_LISTBOX_POS;
ASSET_LISTBOX ctrlSetBackgroundColor [0.1,0.1,0.1,1];
ASSET_LISTBOX ctrlCommit 0;

CURRENT_FUNDING_TEXT = _display ctrlCreate ["RscText", (count PURCHASE_MENU_ITEMS) + 6, ASSET_LISTBOX];
CURRENT_FUNDING_TEXT ctrlSetPosition ([ [-0.25, -0.1, 0.01, 0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
CURRENT_FUNDING_TEXT ctrlSetText format["Funds: %1", [CURRENT_FUNDING_BALANCE, true] call fnc_standardNumericalNotationString];
CURRENT_FUNDING_TEXT ctrlCommit 0;

ASSET_NAME = _display ctrlCreate ["RscText", (count PURCHASE_MENU_ITEMS) + 2, ASSET_LISTBOX];
ASSET_NAME ctrlSetPosition ([ [-0.25,-0.05, 0.01, 0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
ASSET_NAME ctrlSetText "Asset: ";
ASSET_NAME ctrlCommit 0;

ASSET_PRICE = _display ctrlCreate ["RscText", (count PURCHASE_MENU_ITEMS) + 3, ASSET_LISTBOX];
ASSET_PRICE ctrlSetPosition ([ [-0.25,0, 0.01, 0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
ASSET_PRICE ctrlSetText "Price: ";
ASSET_PRICE ctrlCommit 0;

ASSET_TYPE = _display ctrlCreate ["RscText", (count PURCHASE_MENU_ITEMS) + 4, ASSET_LISTBOX];
ASSET_TYPE ctrlSetPosition ([ [-0.25,0.05, 0.01, 0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
ASSET_TYPE ctrlSetText "Type: ";
ASSET_TYPE ctrlCommit 0;

//ASSET_DESCRIPTION = _display ctrlCreate ["RscText", (count PURCHASE_MENU_ITEMS) + 5, ASSET_LISTBOX];
//ASSET_DESCRIPTION ctrlSetPosition ([ [-0.25,0.1,0.001,0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
//ASSET_DESCRIPTION ctrlSetText "Description: ";
//ASSET_DESCRIPTION ctrlCommit 0;

private _ctrlGroup = _display ctrlCreate ["RscControlsGroup", -1]; 
_ctrlGroup ctrlCommit 0;

private _ctrlBackground = _display ctrlCreate ["RscTextMulti", -1, _ctrlGroup]; 	
_ctrlBackground ctrlSetPosition [0, 0, 0, 0]; 
_ctrlBackground ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_ctrlBackground ctrlEnable false; 
_ctrlBackground ctrlCommit 0; 

_groupDesc            = "N/A";
_group_index    	  = 0;
_control_id_index     = 0;
_control_height_index = 0;
_checkBoxes 		  = [];
_groupArray           = [];
{
	// Iterate all groups
	_groupDesc  = _x select 0;
	_groupArray = _x select 1;
	
	{
		// Iterate each asset in group
		private _thisAsset = _x;

		_thisAsset pushBack _groupDesc; // becomes index: 6
		
		private _ctrlEdit   = _display ctrlCreate ["RscButton", _control_id_index, _ctrlGroup]; 
		_ctrlEdit ctrlSetPosition [0, _control_height_index, 0.50, 0.05]; 	

		_ctrlEdit ctrlSetText format["[%1] - %2", _groupDesc, _thisAsset select 1];
		_ctrlEdit setVariable ["OPTION_DATA", _thisAsset];

		_ctrlEdit ctrlAddEventHandler ["ButtonClick", {
			params ["_control"];
			//PURCHASE_MENU_CART_ITEMS = []; // Only one item at a time, for now
			private _optionData = _control getVariable ["OPTION_DATA", []];

			// Push the asset to the cart // todo: make array of items (like before) and allow multiple items in cart.
			PURCHASE_MENU_CART_ITEMS = _optionData;
			
			CURRENT_FUNDING_TEXT ctrlSetText format["Funds: %1", [CURRENT_FUNDING_BALANCE, true] call fnc_standardNumericalNotationString];
			ASSET_NAME  ctrlSetText "Asset: " + (_optionData select 1);
			ASSET_PRICE ctrlSetText "Price: " + ([_optionData select 2, true] call fnc_standardNumericalNotationString);
			ASSET_TYPE  ctrlSetText "Type: " + (_optionData select 6);
			//ASSET_DESCRIPTION ctrlSetText "Description: 
			//<t>" + (_optionData select 3) + "</t>";

			true
		}]; 
		
		_ctrlEdit ctrlCommit 0; 

		// [index, ctrl, assetObject]
		_checkBoxes pushBack [_control_id_index, _ctrlEdit, _thisAsset];

		_control_id_index     = _control_id_index + 1;
		_control_height_index = _control_height_index + 0.05;			

	} forEach _groupArray;

	_group_index = _group_index + 1;

} forEach PURCHASE_MENU_ITEMS;

private _cancel = _display ctrlCreate ["RscShortcutButton", -1, _ctrlBackground]; 
_cancel ctrlSetPosition [0.25, 0.75, 0.25, 0.05]; 
_cancel ctrlCommit 0; 
_cancel ctrlSetText " CANCEL "; 
_cancel ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
 	_display = ctrlParent _ctrl; 
 	_display closeDisplay 1;
	PURCHASE_MENU_OPEN = false; 
}]; 

private _ctrlButton = _display ctrlCreate ["RscShortcutButton", -1, _ctrlBackground]; 
_ctrlButton ctrlSetPosition [0.5, 0.75, 0.25, 0.05]; 
_ctrlButton ctrlCommit 0; 
_ctrlButton ctrlSetText "   BUY"; 
_ctrlButton ctrlAddEventHandler ["ButtonClick",  
{ 

	params ["_ctrl"]; 
	if (count PURCHASE_MENU_CART_ITEMS == 0) exitWith {
		hint "No items in cart!";
	};

	_display = ctrlParent _ctrl; 
	_display closeDisplay 1;

	private _class 	   = PURCHASE_MENU_CART_ITEMS select 0;
	private _name  	   = PURCHASE_MENU_CART_ITEMS select 1;
	private _desc  	   = PURCHASE_MENU_CART_ITEMS select 2;
	private _price 	   = PURCHASE_MENU_CART_ITEMS select 2;
	private _groupDesc = PURCHASE_MENU_CART_ITEMS select 4; 
	private _initScript= PURCHASE_MENU_CART_ITEMS select 5; 
	private _initTarget= PURCHASE_MENU_CART_ITEMS select 6; 

	if (_price <= CURRENT_FUNDING_BALANCE) then {
		[_price] call fnc_subtractFunding;
	
	    private _padPos   = [] call fnc_getEmptySpawnPad;
		private _spawnPos = [];
		if (typeName _padPos != "BOOL") then 
		{
			//private _dropHeight = [[0, 0, 100], _padPos] call BIS_fnc_vectorAdd;
			//_spawnPos = [_dropHeight, 0, 5, 3, 0, 20, 0] call BIS_fnc_findSafePos;
			_spawnPos = _padPos;
			//systemChat format["Spawning %1 at parking spot %2", typeOf _vehicle, _padPos];
		} else {
			_spawnPos = [getPos respawn_vehicle_west, 1, 100, 5, 0, 20, 0] call BIS_fnc_findSafePos;
			//systemChat format["Spawning %1 at overflow spot (random) %2", typeOf _vehicle, _padPos];
		};
		
		private _vehicle = createVehicle [_class, _spawnPos, [], 0, "NONE"];
		
		_vehicle allowDamage false;
		[_vehicle] spawn {
			sleep 1;
			(_this select 0) allowDamage true;
		};

		[[_vehicle], "server\asset.sqf"] remoteExec ["execVM", 2]; // process as an asset
		//_vehicle setVehicleInit _initScript; // Set init script - networked - DISABLED IN A3 FOR SECURITY REASONS!
		[_vehicle, _initScript] remoteExec ["fnc_addToPurchasedVehicles", 2]; // Add to purchased vehicles - Server
		hint format["Remaining Balance: %1", [CURRENT_FUNDING_BALANCE, true] call fnc_standardNumericalNotationString];
	} else {
		hint format["Insufficient Funds To Purchase %1!", _name];
		break;
	};
		
	PURCHASE_MENU_CART_ITEMS = [];	
	PURCHASE_MENU_OPEN       = false;
	true 
}]; 
ctrlSetFocus (_checkBoxes select 0 select 1); 
_ctrlGroup ctrlSetPosition [0.25, 0.25, 0.5, 0.5]; 
_ctrlGroup ctrlCommit 0.1; 
playSound "Hint3";