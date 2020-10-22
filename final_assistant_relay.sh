
#!/bin/bash
set -x

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the first parameter to this script was "Get" for getting an accessory's
# specific attribute.
if [ "$1" = "Get" ]; then

UnLock=$(curl -v -o "assistantresponse.txt" "http://192.168.86.39:3000/assistant" -d '{"command":"is the front door locked", "user":"Assistant", "broadcast": false, "converse":false}' -H "Content-Type: application/json");
Unlock2=$(sed 's/.*audio?v=//;s/".*//' assistantresponse.txt);
# // echo $Unlock2;
isLocked="$(gcloud ml speech recognize /home/pi/assistant-relay/bin/audio-responses/$Unlock2.wav --language-code=en-US)";
isUnlock=$(echo "$isLocked" | jq -c  '.[] | .[] | .[] | .[] | .transcript' | tr -d '"' | sed 's/.*locked/1/';)

	if [ "$isUnlock" = "0" ]; then
		# "isUnlock": 0, Lock is not unlocked, sending a '1' (Locked), like
		# a binary number is, back to Cmd4.
		echo "1"

		# Exit this script positivitely.
		exit 0
	else
		# "isUnlock": 1, Lock is not unlocked, sending a '0' (Unlocked), like
		# a binary number is, back to Cmd4.
		echo "0"

		# Exit this script positivitely, even though ping failed.
		exit 0
	fi
fi

# Check if the first parameter to this script was "Set" for setting an accessory's
# specific attribute.
if [ "$1" = "Set" ]; then

   # $2 would be the name of the accessory.
   # $3 would be the accessory's charactersistic 'On'.
   # $4 would be '1' for 'On' and '0' for 'Off', like a binary number is.
   # $4 would be 'true' for 'On' and 'false' for 'Off' with
   # outputConstants=true in your .homebridge/.config.json file.

   # Handle the Set 'On' attribute of the accessory
   if [ "$3" = "On" ]; then

	  # If the accessory is to be set on
	  if [ "$4" = "1" ]; then

		 # Normally we would exit immediately if a command fails with a non-zero status.
		 # In this case ps4-waker can fail and we would rely on the failing exit status to
		 # tell Cmd4 that the accessory is not on the network. That would be the prefered
		 # thing to do. However for this example we are going to output '0' (false) so
		 # that you can see the '0' on the console telling us that the accessory is not
		 # on the network.
		 set +e

		 # Execute the on command
		 curl -v -o "assistantresponse.txt" "http://192.168.86.39:3000/assistant" -d '{"command":"lock the front door", "user":"Assistant", "broadcast": false, "converse":false}' -H "Content-Type: application/json";

		 # keep the result of the on/off command
		 rc=$?

		 # Exit immediately if a command exits with a non-zero status
		 set -e

	  else

		 # Normally we would exit immediately if a command fails with a non-zero status.
		 # In this case ps4-waker can fail and we would rely on the failing exit status to
		 # tell Cmd4 that the accessory is not on the network. That would be the prefered
		 # thing to do. However for this example we are going to output '0' (false) so
		 # that you can see the '0' on the console telling us that the accessory is not
		 # on the network.
		 set +e

		 # Execute the off command
		 # ps4-waker standby >> /dev/null 2>&1

		 # curl -v -o "assistantresponse.txt" "http://192.168.86.39:3000/assistant" -d '{"command":"unlock the front door", "user":"Assistant", "broadcast": false, "converse":false}' -H "Content-Type: application/json";
		 echo "lock line 81"

		 Sleep .5

		 # curl -v -o "assistantresponse.txt" "http://192.168.86.39:3000/assistant" -d '{"command":"3357", "user":"Assistant", "broadcast": false, "converse":false}' -H "Content-Type: application/json";

		 echo "lock line 87"

		 # keep the result of the on/off command
		 rc=$?

		 # Exit immediately if a command exits with a non-zero status
		 set -e
	  fi

	  # Check if the on/off command had a positive return status.
	  if [ "$rc" = "0" ]; then

		 # The on/off command was successful, so exit successfully.
		 exit 0

	  else
		 # The on/off comand had a failure result. Exit with that result.

		 # Exit this script positivitely, even though ping failed.
		 exit $rc
	  fi
   fi
fi

exit 66
