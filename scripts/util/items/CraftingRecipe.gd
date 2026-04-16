class_name CraftingRecipe
extends Resource


@export var ingredients : Array[CraftingIngredient]

@export var output : CraftingIngredient


func craft(inventory: Inventory) -> void:
	
	for ingredient in ingredients:
		inventory.remove_item(ingredient.item, ingredient.count)
	
	inventory.add_item(ItemStack.new(output.item, output.count))


func can_craft(inventory: Inventory) -> bool:
	var valid = true
	
	for ingredient in ingredients:
		if !inventory.has_count(ingredient.item, ingredient.count):
			valid = false
	
	return valid
