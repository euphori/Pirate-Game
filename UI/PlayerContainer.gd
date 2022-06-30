extends ScrollContainer

const SlotClass = preload("res://Inventory/Slot.gd")
onready var inventory_slots = $PlayerSlots
onready var trade_ui = get_parent()

var valid_holder = ["player", "none", "seller"]

func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].inventory_name = "TradeUI"
	initialize_inventory()

func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1], "player")

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if trade_ui.holding_item != null:
				if valid_holder.has(trade_ui.holding_item.item_holder):
					if !slot.item: #Place holding item to slot

						left_click_empty_slot(slot)
					else: #swap holding item to slot
						if trade_ui.holding_item.item_name != slot.item.item_name:
							left_click_different_item(event, slot)
						else:
							left_click_same_item(slot)
			elif slot.item:
				left_click_not_holding_item(slot)
		
func _input(event):

	if trade_ui.holding_item:
		trade_ui.holding_item.global_position = get_global_mouse_position()
	


func left_click_empty_slot(slot: SlotClass):
#	PlayerInventory.add_item_to_empty_slot(trade_ui.holding_item, slot)
	change_holder(slot, "player")
	slot.put_into_slot(trade_ui.holding_item)
	trade_ui.holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
#	PlayerInventory.remove_item(slot)
#	PlayerInventory.add_item_to_empty_slot(trade_ui.holding_item, slot)
	
	var temp_item = slot.item
	slot.pick_from_slot()
	temp_item.global_position = event.global_position
	slot.put_into_slot(trade_ui.holding_item)
	trade_ui.holding_item = temp_item

func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= trade_ui.holding_item.item_quantity:
#		PlayerInventory.add_item_quantity(slot, trade_ui.holding_item.item_quantity)
		slot.item.add_item_quantity(trade_ui.holding_item.item_quantity)
		trade_ui.holding_item.queue_free()
		trade_ui.holding_item = null
	else:
#		PlayerInventory.add_item_quantity(slot, able_to_add)
		slot.item.add_item_quantity(able_to_add)
		trade_ui.holding_item.subtract_item_quantity(able_to_add)

func left_click_not_holding_item(slot: SlotClass):
#	PlayerInventory.remove_item(slot)
	trade_ui.holding_item = slot.item
	slot.pick_from_slot()
	trade_ui.holding_item.global_position = get_global_mouse_position()

func change_holder(slot: SlotClass, item_holder):
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if slots[i].item != null:
			slots[i].item.item_holder = item_holder
