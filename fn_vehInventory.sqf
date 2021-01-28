#include "..\..\script_macros.hpp"
/*
    File: fn_vehInventory.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Used a refresher for the vehicle inventory / trunk menu items.
*/
private ["_veh","_tInv","_pInv","_veh_data"];
_veh = param [0,objNull,[objNull]];
if (isNull _veh || !alive _veh) exitWith {closeDialog 0;}; //If null / dead exit menu
disableSerialization;

_tInv = CONTROL(3500,3502);
_pInv = CONTROL(3500,3503);
lbClear _tInv;
lbClear _pInv;

_veh_data = [_veh] call life_fnc_vehicleWeight;

if ((_veh_data select 0) isEqualTo -1) exitWith {closeDialog 0};

ctrlSetText[3504,format ["Weight: %1/%2",(_veh_data select 1),(_veh_data select 0)]];
_data = _veh getVariable ["Trunk",[]];
if (count _data isEqualTo 0) then {_veh setVariable ["Trunk",[[],0],true]; _data = [];} else {_data = (_data select 0);};
//Player Inventory Items
{
    _val = ITEM_VALUE(configName _x);

    if (_val > 0) then {
        _pInv lbAdd format ["[%1] - %2",_val,localize (getText(_x >> "displayName"))];
        _pInv lbSetData [(lbSize _pInv)-1,configName _x];
        _icon = (getText(_x >> "icon"));
        if (!(_icon isEqualTo "")) then {
            _pInv lbSetPicture [(lbSize _pInv)-1,_icon];
        };
    };
} forEach ("true" configClasses (missionConfigFile >> "VirtualItems"));

//Trunk Inventory Items
{
    _name = M_CONFIG(getText,"VirtualItems",(_x select 0),"displayName");
    _val = (_x select 1);

    if (_val > 0) then {
        _tInv lbAdd format ["[%1] - %2",_val,localize _name];
        _tInv lbSetData [(lbSize _tInv)-1,(_x select 0)];
        _icon = M_CONFIG(getText,"VirtualItems",(_x select 0),"icon");
        if (!(_icon isEqualTo "")) then {
            _tInv lbSetPicture [(lbSize _tInv)-1,_icon];
        };
    };
} forEach _data;

_pInv ctrlAddEventHandler ["LBDblClick", {
	params ["_control", "_selectedIndex"];
    disableSerialization;
    private _item = (_control lbData _selectedIndex);
    private _items_player = format["life_inv_%1", _item];
    _items_player = call compile format["%1", _items_player];
    private _weight_veh = [life_trunk_vehicle] call life_fnc_vehicleWeight;
    _diff = [_item,_items_player,(_weight_veh # 1),(_weight_veh # 0) ] call life_fnc_calWeightDiff;
    if (_diff <= 0) then {
         ((findDisplay 3500) displayCtrl 3506) ctrlSetText "0";
         hint "Vous ne pouvez pas déposer plus";
    } else {
        ((findDisplay 3500) displayCtrl 3506) ctrlSetText format["%1",_diff];
        [] call life_fnc_vehStoreItem;
    };
}];
_tInv ctrlAddEventHandler ["LBDblClick", {
    params ["_control", "_selectedIndex"];
    disableSerialization;
    private _item = (_control lbData _selectedIndex);
    private _index = [_item,((life_trunk_vehicle getVariable "Trunk") # 0)] call TON_fnc_index;
    if (_index isEqualTo -1) exitWith {};
    private _data = (life_trunk_vehicle getVariable "Trunk") # 0;
    private _value = ((_data # _index) # 1);
    _diff = [_item,_value,life_carryWeight,life_maxWeight] call life_fnc_calWeightDiff;
    if (_diff <= 0) then {
         ((findDisplay 3500) displayCtrl 3505) ctrlSetText "0";
            hint "Vous ne pouvez pas récuperer plus";
    } else {
        ((findDisplay 3500) displayCtrl 3505) ctrlSetText format["%1",_diff];
        [] call life_fnc_vehTakeItem;
    };
}];