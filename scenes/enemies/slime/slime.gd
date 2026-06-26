class_name Slime extends Enemy

# Exposed so the player's damage handler can apply knockback to us.
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
