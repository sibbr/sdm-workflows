#!/bin/bash
# workflow_config.sh - Wizard to configure the workflow.
# Based on http://aurelio.net/shell/dialog/navegando.sh

# This variable defines the next step in the wizard.
next=first

# main loop
while : ; do

	# Here is identified which screen should be shown.
	# In each screen the variables 'previous' and 'next'
	# are defined. They define the navigation directions. 
	case "$next" in
		first)
			next=occurrences_file
			dialog --backtitle 'Workflow configuration' \
				--ok-label 'Next' \
				--msgbox 'Welcome to the workflow configuration' 20 70
		;;
		occurrences_file)
			previous=first
			next=min_occurrences
			occurrences_file=$(dialog --stdout \
				--title 'Select the occurrences file' \
				--backtitle 'Workflow configuration' \
				--ok-label 'Next' \
				--cancel-label 'Previous' \
				--fselect ./ 20 70)
		;;
		min_occurrences)
			previous=occurrences_file
			next=mask_file
			min_occurrences=$(dialog --stdout \
				--title 'Minimum number of occurrences' \
				--backtitle 'Workflow configuration'   \
				--ok-label 'Next' \
				--cancel-label 'Previous' \
				--inputbox 'Only species with this number of occurrences or more will be modeled' 0 0)
				# TODO validate user input
		;;
		mask_file)
			previous=min_occurrences
			next=output_format_file
			mask_file=$(dialog --stdout \
				--title 'Mask to delimit the region to be used to generate the model' \
				--backtitle 'Workflow configuration'	\
				--ok-label 'Next' \
				--cancel-label 'Previous' \
				--fselect ./ 20 70)
		;;
		output_format_file)
			previous=mask_file
			next=output_mask_file
			output_format_file=$(dialog --stdout \
				--title 'File to be used as the output format' \
				--backtitle 'Workflow configuration' \
				--ok-label 'Next' \
				--cancel-label 'Previous' \
				--fselect ./ 20 70)
		;;
		output_mask_file)
			previous=output_format_file
			next=map_list
			output_mask_file=$(dialog --stdout \
				--title 'Mask to delimit the region to project the model onto' \
				--backtitle 'Workflow configuration' \
				--ok-label 'Next' \
				--cancel-label 'Previous' \
				--fselect ./ 20 70)
		;;
		map_list)
			previous=output_mask_file
			next=output_map_list

			unset map_list
			while : ; do
					map_list=$map_list,$(dialog --stdout \
					--title 'Maps to be used as environmental variables to generate the model' \
					--backtitle 'Workflow configuration' \
					--ok-label 'Next' \
					--cancel-label 'Previous' \
					--fselect ./ 20 70) 
					return=$?
					[ $return -eq 1		] && { next=output_mask_file; break; }
					[ $return -eq 255	] &&  exit
					dialog --yes-label 'Yes' --no-label 'No' --yesno 'Add one more file?' 0 0
					return=$?
					[ $return -eq 1		] && break
					[ $return -eq 255	] && exit
			done
		;;
		output_map_list)
			previous=map_list
			next=final

			unset output_map_list
			while : ; do
					output_map_list=$output_map_list,$(dialog --stdout \
					--title 'Maps to be used as environmental variables to project the model to create the output distribution map' \
					--backtitle 'Workflow configuration' \
					--ok-label 'Next' \
					--cancel-label 'Previous' \
					--fselect ./ 20 120)
					return=$?
					[ $return -eq 1	] && { next=map_list; break; }
					[ $return -eq 255	] &&  exit
					dialog --yes-label 'Yes' --no-label 'No' --yesno 'Add one more file?' 0 0
					return=$?
					[ $return -eq 1    ] && break
					[ $return -eq 255  ] && exit
			done
		;;
		final)
			previous=output_map_list

			# If the user got here the workflow can be executed.
			run_swift=yes

			# Removing the comma from the beginning of the lists
			map_list=${map_list#,}
			output_map_list=${output_map_list#,}

			dialog \
				--backtitle 'Workflow configuration'   \
				--title 'Configuration summary' \
				--yes-label 'Yes' \
				--no-label 'No' \
				--yesno "
				Occurrences file: $occurrences_file
				Minimum occurrences: $min_occurrences
				Mask: $mask_file
				Output format file: $output_format_file
				Output mask file: $output_mask_file
				Maps to be used as environmental variables to generate the model:
				$(sed 's/,/\n\t/g' <<< $map_list)
				Maps to be used as environmental variables to project the model to create the output distribution map:
				$(sed 's/,/\n\t/g' <<< $output_map_list)

				Run workflow?
				" 0 0
				return=$?
				[ $return -eq 0		] && break
				[ $return -eq 1		] && next=output_map_list
				[ $return -eq 255	] && exit
		;;
		*)
			echo "Unknown screen '$next'."
			echo Aborting...
			exit
	esac

	# Generic treatment of exit statuses.
	# Go back one screen if the user hits 'Previous' and
	# exit the script if the user hits Esc.
	return=$?
	[ $return -eq 1   ] && next=$previous   # Previous
	[ $return -eq 255 ] && break			# Esc

done

clear

# Do the user reached the end of the wizard? If yes, run the workflow.
[ "$run_swift" = 'yes' ] && swift -tc.file tc.data -sites.file sites.xml workflow-openmodeller.swift \
	-o="$occurrences_file" \
	-min-occ="$min_occurrences" \
	-mask-file="$mask_file" \
	-output-format="$output_format_file" \
	-output-mask="$output_mask_file" \
	-maps="$map_list" \
	-output-maps="$output_map_list"
