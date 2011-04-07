# ------------------------------------------------------------------------------
# Core class
# ------------------------------------------------------------------------------

# SU_Utils: This is the main utility class.
#
# Encapsulate all the utilities into a Class so there is no conflict with other
# plugins. 
#
# This class provides some useful tools for Google SketchUp: 
# 
# * hide_layers
# * isolate_layers
# * hide_entities
# * isolate_entities
# * freeze_groups_and_components
# * unfreeze_all
# * show_all
# 
# These tools can be mapped to shortcut keys to make it easy to work on 
# a specific piece of your model.
# 
# See the README for more information about this plugin.
# 
# TODO: Get show_all to show hidden entites WITHIN groups.



class SU_Utils
  
  def initialize
    @model = Sketchup.active_model
    @selection = @model.selection
    @entities = @model.entities
    @layers = @model.layers
    @debug = UTILITIES_DEBUG
  end

  # Isolate selected layers.
  # Hide all layers that are not within the selection.
  def isolate_layers
    selection_layers = @selection.collect { |s| s.layer }.to_a
    puts "Isolating #{selection_layers.length} layers..." if @debug
    layers_to_hide = @layers.to_a - selection_layers.to_a
    if not @selection.empty?
      @model.start_operation "Isolate selected layers"
        layers_to_hide.each { |l|
          puts "Making layer '#{l}' hidden..." if @debug
          l.visible = false 
        }
      @model.commit_operation
    else
      puts "Nothing selected!!!" if @debug
    end
  end
  
  # Hide selected layers.
  # Grabs all layers in selection and turns their visibility off.
  def hide_layers
    selection_layers = @selection.collect { |s| s.layer }.to_a
    if not @selection.empty?
      @model.start_operation "Hide selected layers"
        selection_layers.each { |l|
          puts "Making layer '#{l}' hidden..." if @debug
          l.visible = false
        }
      @model.commit_operation
    else
      puts "Nothing selected!!!" if @debug
    end
  end

  # Isolate selected entities.
  # Hides all entities other than the selected entity.
  def isolate_entities
    if !@selection.empty?
      @model.start_operation "Isolate selected entities"
        entities_to_hide = @entities.to_a - @selection.to_a
        puts "Isolating #{entities_to_hide.length} entities..." if @debug
        entities_to_hide.each { |e|
          puts "Making '#{e}' entity hidden..." if @debug
          e.visible = false
        }
      @model.commit_operation
    else
      puts "Nothing selected!!!" if @debug
    end
  end

  # Hide selected entities.
  # Hide all entities within the selection.
  def hide_entities
    if not @selection.empty?
      @model.start_operation "Hide selected entities"
        @selection.each { |e|
          puts "Making '#{e}' entity hidden..." if @debug
          e.visible = false
        }
      @model.commit_operation
    else
      puts "Nothing selected!!!" if @debug
    end
  end
  
  # Freeze selected entities.
  # Hides and locks all groups and components within the selection. 
  # Since lock only works on groups or components, this tool will only work 
  # on groups and components.
  def freeze_groups_and_components
    if not @selection.empty?
      @model.start_operation "Freeze groups and components"
        puts "Freezing selection..." if @debug
        @selection.each { |e| 
          if e.typename == "Group" or e.typename == "ComponentInstance"
            puts "Making '#{e}' entity hidden and locked..." if @debug
            e.visible = false
            e.locked = true
          end
        }
      @model.commit_operation
    else
      puts "Nothing selected!!!" if @debug
    end
  end
  
  # Freeze selected entities.
  # Hides and locks all groups and components within the selection. 
  # Since lock only works on groups or components, this tool will only work 
  # on groups and components.
  def unfreeze_all
    @model.start_operation "Unfreeze everything"
      puts "Unfreezing everything..." if @debug
      @entities.each { |e| 
        if e.typename == "Group" or e.typename == "ComponentInstance"
          if e.locked? and not e.visible?
            puts "Making '#{e}' entity visible and unlocked..." if @debug
            e.locked = false
            e.visible = true
          end
        end
      }
    @model.commit_operation
  end

  # Show all
  # Unhides all hidden layers and entities. If a layer is locked and hidden, 
  # assume it is frozen, so do not unhide it.
  def show_all
    @model.start_operation "Show all layers and entities"
      puts "Showing all layers and entities..." if @debug
      @layers.each { |l|
        puts "Making layer '#{l}' visible..." if @debug
        l.visible = true
      }
      @entities.each { |e|
        # If the entity is a Group or Component, test if it is frozen.
        if e.typename == "Group" or e.typename == "ComponentInstance"
          if not e.visible? and e.locked?
            puts "'#{e}' is hidden and locked, do no show it..." if @debug
          else
            puts "Making '#{e}' entity visible..." if @debug
            e.visible = true
          end
        else
          puts "Making '#{e}' entity visible..." if @debug
          e.visible = true
        end
        
      }
    @model.commit_operation
  end

end

# ------------------------------------------------------------------------------
# UI features
# ------------------------------------------------------------------------------

# Create the commands for the utility class, create and show the toolbar, context 
# menus and the menu items for the tools.
#
# Only load these tools if the SU_Utils.rb file is not already loaded.
if not file_loaded?(File.join(UTILITIES_BASE_PATH, "SU_Utils/Utilities.rb"))
  
  # ----------------------------------------------------------------------------
  # Create the various Utility commands
  # ----------------------------------------------------------------------------
  
  # Create the hide_layers command.
  hide_layers_cmd = UI::Command.new("Hide Layers") { 
    SU_Utils.new().hide_layers()
  }
  hide_layers_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/hide_layers_small.png")
  hide_layers_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/hide_layers_large.png")
  hide_layers_text = "Hide selected layers"
  hide_layers_cmd.tooltip = hide_layers_text
  hide_layers_cmd.menu_text = hide_layers_text
  hide_layers_cmd.status_bar_text = hide_layers_text
  
  # Create the isolate_layers command.
  isolate_layers_cmd = UI::Command.new("Isolate Layers") { 
    SU_Utils.new().isolate_layers()
  }
  isolate_layers_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/isolate_layers_small.png")
  isolate_layers_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/isolate_layers_large.png")
  isolate_layers_text = "Isolate selected layers"
  isolate_layers_cmd.tooltip = isolate_layers_text
  isolate_layers_cmd.menu_text = isolate_layers_text
  isolate_layers_cmd.status_bar_text = isolate_layers_text
  
  # Create the hide_entities command.
  hide_entities_cmd = UI::Command.new("Hide Entities") { 
    SU_Utils.new().hide_entities()
  }
  hide_entities_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/hide_entities_small.png")
  hide_entities_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/hide_entities_large.png")
  hide_entities_text = "Hide selected entities"
  hide_entities_cmd.tooltip = hide_entities_text
  hide_entities_cmd.menu_text = hide_entities_text
  hide_entities_cmd.status_bar_text = hide_entities_text
  
  # Create the hide_layers command.
  isolate_entities_cmd = UI::Command.new("Isolate Entities") { 
    SU_Utils.new().isolate_entities()
  }
  isolate_entities_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/isolate_entities_small.png")
  isolate_entities_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/isolate_entities_large.png")
  isolate_entities_text = "Isolate selected entities"
  isolate_entities_cmd.tooltip = isolate_entities_text
  isolate_entities_cmd.menu_text = isolate_entities_text
  isolate_entities_cmd.status_bar_text = isolate_entities_text
  
  # Create the freeze_entities command.
  freeze_groups_and_components_cmd = UI::Command.new("Freeze Groups and Components") { 
    SU_Utils.new().freeze_groups_and_components()
  }
  freeze_groups_and_components_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/freeze_groups_and_components_small.png")
  freeze_groups_and_components_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/freeze_groups_and_components_large.png")
  freeze_groups_and_components_text = "Freeze groups and components"
  freeze_groups_and_components_cmd.tooltip = freeze_groups_and_components_text
  freeze_groups_and_components_cmd.menu_text = freeze_groups_and_components_text
  freeze_groups_and_components_cmd.status_bar_text = freeze_groups_and_components_text
  
  # Create the unfreeze_all command.
  unfreeze_all_cmd = UI::Command.new("Unfreeze All") { 
    SU_Utils.new().unfreeze_all()
  }
  unfreeze_all_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/unfreeze_all_small.png")
  unfreeze_all_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/unfreeze_all_large.png")
  unfreeze_all_text = "Unfreeze all"
  unfreeze_all_cmd.tooltip = unfreeze_all_text
  unfreeze_all_cmd.menu_text = unfreeze_all_text
  unfreeze_all_cmd.status_bar_text = unfreeze_all_text
  
  # Create the hide_layers command.
  show_all_cmd = UI::Command.new("Show All") { 
    SU_Utils.new().show_all()
  }
  show_all_cmd.small_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/show_all_small.png")
  show_all_cmd.large_icon = File.join(UTILITIES_BASE_PATH, "SU_Utils/images/show_all_large.png")
  show_all_text = "Show all layers and entities"
  show_all_cmd.tooltip = show_all_text
  show_all_cmd.menu_text = show_all_text
  show_all_cmd.status_bar_text = show_all_text
  
  # ----------------------------------------------------------------------------
  # Create and add the Utilities submenu.
  # ----------------------------------------------------------------------------
  utils_submenu = UI.menu("Plugins").add_submenu "Utilities"
  utils_submenu.add_item isolate_layers_cmd
  utils_submenu.add_item hide_layers_cmd
  utils_submenu.add_item isolate_entities_cmd
  utils_submenu.add_item hide_entities_cmd
  utils_submenu.add_item freeze_groups_and_components_cmd
  utils_submenu.add_item unfreeze_all_cmd
  utils_submenu.add_item show_all_cmd
  
  # ----------------------------------------------------------------------------
  # Create and add the Utilities context menu shortcuts.
  # ----------------------------------------------------------------------------
  UI.add_context_menu_handler do |context_menu|
    context_menu.add_separator
    utils_context_submenu = context_menu.add_submenu "Utilities"
    utils_context_submenu.add_item isolate_layers_cmd
    utils_context_submenu.add_item hide_layers_cmd
    utils_context_submenu.add_item isolate_entities_cmd
    utils_context_submenu.add_item hide_entities_cmd
    utils_context_submenu.add_item freeze_groups_and_components_cmd
    utils_context_submenu.add_item unfreeze_all_cmd
    utils_context_submenu.add_item show_all_cmd
  end

  # ----------------------------------------------------------------------------
  # Create and add the Utilities toolbar.
  # ----------------------------------------------------------------------------
  utils_toolbar = UI::Toolbar.new("Utilities")
  utils_toolbar.add_item isolate_layers_cmd
  utils_toolbar.add_item hide_layers_cmd
  utils_toolbar.add_item isolate_entities_cmd
  utils_toolbar.add_item hide_entities_cmd
  utils_toolbar.add_item freeze_groups_and_components_cmd
  utils_toolbar.add_item unfreeze_all_cmd
  utils_toolbar.add_item show_all_cmd
  if utils_toolbar.get_last_state != 0
    utils_toolbar.show  
  end

end

file_loaded(File.join(UTILITIES_BASE_PATH, "SU_Utils/Utilities.rb"))
