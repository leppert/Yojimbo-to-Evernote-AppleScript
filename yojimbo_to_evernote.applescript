(*
Import Yojimbo items into Evernote
Author: Brett Kelly - brett@brettkelly.org
Version: 0.1

Imports all database items from Yojimbo into Evernote
- Preserves tags and creation dates
- Imports all items into a new notebook called "Yojimbo Items"

*** THIS SCRIPT IS GOING TO CREATE A TON OF FILES IN YOUR HOME DIRECTORY ***
They will all have similar names starting with "tmp", so they'll be easy to delete
once this thing is done.  I'm just as unhappy about this as you are, believe me.
I'm looking for a more elegant way to handle this, but AS's handling of 
files and directories is freaking *weird*.

For Web Archive Items:

- Since Yojimbo doesn't expose the actual contents of web archives (the HTML, etc.), this script
will re-clip the current content from the source URL of the web archive.  This is very likely to 
produce unexpected results if the archived site no longer exists, for example.  YMMV.

There is virtually *no* error checking in this application, currently.  It is not destructive to your Yojimbo data.

To allow passwords and encrypted items to be imported into Evernote, you need to modify the security settings in Yojimbo:
Go to Preferences -> Security and check the "Accessing password items from scripts" and
"Accessing encrypted items from scripts" under the "Allow Yojimbo to use the Keychain when:" section.
Please know that allowing this sort of access is extremely unsecure and will likely result 
in the loss of your favorite shirt.  Data that is encrypted in Yojimbo will *not* be encrypted
once it is added to Evernote.

This is currently turned on, but can be disabled by changing the two values below to "false"
*)
property doPasswords : true
property doEncryptedNotes : true

(*
TODO:
- Factor out all of the fugly duplicate code
- Move individual note type handling code into discrete routines
- Check for existence of target Evernote notebook, use another if exists
- Remove all temp files created.
- Error checking on I/O operations
- 
*)

set homeDir to ((get path to home folder) as string)
property tNotebook : "Yojimbo Items"
property altNotebook : "Yojimbo Import"

tell application "Evernote"
	-- this is where we'd make sure the notebook didn't already exist
	-- if we didn't totally suck at applescript
end tell

tell application "Yojimbo"
	set yimages to every image item
	set ybkmks to every bookmark item
	set ynotes to every note item
	set ypwds to every password item
	set ypdfs to every pdf archive item
	set yserials to every serial number item
	set ywebs to every web archive item
	
	repeat with yimg in yimages
		-- write image to a file
		set fname to "tmpimage.jpg"
		set tmpFile to homeDir & fname
		set efile to (export yimg to file tmpFile)
		set yimgTitle to name of yimg
		set yimgMod to modification date of yimg
		set yimgTags to tags of yimg
		set ytags to {}
		repeat with t in yimgTags
			copy the name of t as string to the end of ytags
		end repeat
		tell application "Evernote"
			create note from file efile title yimgTitle created yimgMod notebook tNotebook tags ytags
		end tell
		-- delete the image file here, stupid.
	end repeat
	
	repeat with ybk in ybkmks
		set bLoc to location of ybk
		set bTitle to name of ybk
		set bMod to modification date of ybk
		set bTags to tags of ybk
		if comments of ybk is not missing value then
			set bTxt to comments of ybk
		else
			set bTxt to location of ybk
		end if
		set eTags to {}
		repeat with t in bTags
			copy the name of t as string to the end of eTags
		end repeat
		tell application "Evernote"
			set cNote to (create note with text bTxt title bTitle created bMod tags eTags notebook tNotebook)
			set source URL of cNote to bLoc
		end tell
	end repeat
	
	repeat with ynt in ynotes
		if doEncryptedNotes and ynt is encrypted then
			set bTitle to name of ynt
			set bMod to modification date of ynt
			set nTags to tags of ynt
			set nProps to the properties of ynt
			set nBody to contents of nProps
			set fTags to {}
			repeat with tg in nTags
				copy the name of tg as string to the end of fTags
			end repeat
			log fTags
			tell application "Evernote"
				-- create note with text bTxt title bTitle created bMod  notebook tNotebook
				create note with text nBody title bTitle created bMod tags fTags notebook tNotebook
			end tell
		end if
	end repeat
	
	repeat with ypwd in ypwds
		set bTitle to name of ypwd
		set bMod to modification date of ypwd
		set nTags to tags of ypwd
		set nProps to the properties of ypwd
		set nLocation to the location of ypwd
		set nAcct to the account of ypwd
		if doPasswords then
			try
				set nPass to the password of ypwd
			on error
				set nPass to "<Security Policy Enforced, Password not Imported>"
			end try
		else
			set nPass to "<Password Omitted>"
		end if
		set nBody to ""
		
		if nLocation is not missing value then
			set nBody to (nBody & "Location: " & nLocation & return)
		end if
		
		if nAcct is not missing value then
			set nBody to (nBody & "Account: " & nAcct & return)
		end if
		
		set nBody to (nBody & return & "Password: " & nPass)
		
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		
		tell application "Evernote"
			create note with text nBody title bTitle created bMod tags fTags notebook tNotebook
		end tell
	end repeat
	
	repeat with ypdf in ypdfs
		set fname to "tmpdoc.pdf"
		set tmpFile to homeDir & fname
		set efile to (export ypdf to file tmpFile)
		set ypdfTitle to name of ypdf
		set ypdfMod to modification date of ypdf
		set ypdfTags to tags of ypdf
		set ptags to {}
		repeat with t in ypdfTags
			copy the name of t as string to the end of ptags
		end repeat
		tell application "Evernote"
			create note from file efile title ypdfTitle created ypdfMod notebook tNotebook tags ptags
		end tell
		-- delete the pdf
	end repeat
	
	repeat with yserial in yserials
		set bTitle to name of yserial
		set bMod to modification date of yserial
		set nTags to tags of yserial
		set nProps to the properties of yserial
		set nOwner to the owner name of yserial
		set nEmail to the email address of yserial
		set nOrg to the organization of yserial
		set nSerial to the serial number of yserial
		set nBody to ""
		if nOwner is not missing value and nOwner is not "" then
			set nBody to nBody & "Owner: " & nOwner & return
		end if
		if nEmail is not missing value and nEmail is not "" then
			set nBody to nBody & "Email Address: " & nEmail & return
		end if
		if nOrg is not missing value and nOrg is not "" then
			set nBody to nBody & "Organization: " & nOrg & return
		end if
		if nSerial is not missing value and nSerial is not "" then
			set nBody to nBody & "Serial Number: " & nSerial & return
		end if
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		tell application "Evernote"
			create note with text nBody title bTitle created bMod tags fTags notebook tNotebook
		end tell
	end repeat
	
	repeat with yweb in ywebs
		set bTitle to name of yweb
		set bMod to modification date of yweb
		set nTags to tags of yweb
		set nProps to the properties of yweb
		set nSource to the source URL of yweb
		set nBody to the source URL of nProps
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		tell application "Evernote"
			create note from url nSource title bTitle created bMod tags fTags notebook tNotebook
		end tell
		
	end repeat
end tell

