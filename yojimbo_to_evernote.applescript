property doPasswords : true -- set to doPasswords and doEncryptedNotes to false disable import of password protected notes
property doEncryptedNotes : true
property separateFolders : true
property addTypeTags : true
property addYojimboTag : true
property maxTitleLength : 255

set homeDir to ((get path to home folder) as string)
property tNotebook : "Yojimbo Items"
property altNotebook : "Yojimbo Import"

tell application "Evernote"
	-- this is where we'd make sure the notebook didn't already exist
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
		if separateFolders then set tNotebook to "Yojimbo Images"
		-- write image to a file
		set fname to "tmpimage.jpg"
		set tmpFile to homeDir & fname
		set efile to (export yimg to file tmpFile)
		set bTitle to name of yimg
		set bMod to modification date of yimg
		set bCreate to creation date of yimg
		set yimgTags to tags of yimg
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set ytags to {}
		repeat with t in yimgTags
			copy the name of t as string to the end of ytags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of ytags
		if addTypeTags then copy "image" as string to the end of ytags
		tell application "Evernote"
			create note from file efile title bTitle created bCreate notebook tNotebook tags ytags
		end tell
		-- delete the image file here, stupid.
	end repeat
	
	repeat with ybk in ybkmks
		if separateFolders then set tNotebook to "Yojimbo Bookmarks"
		set bLoc to location of ybk
		set bTitle to name of ybk
		set bMod to modification date of ybk
		set bCreate to creation date of ybk
		set bTags to tags of ybk
		if comments of ybk is not missing value then
			set nBody to comments of ybk
		else
			set nBody to ""
			-- set nBody to location of ybk
		end if
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set nBody to "Full title: " & bTitle & return & return & nBody
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set eTags to {}
		repeat with t in bTags
			copy the name of t as string to the end of eTags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of eTags
		if addTypeTags then copy "bookmark" as string to the end of eTags
		
		tell application "Evernote"
			set cNote to (create note with text nBody title bTitle created bCreate tags eTags notebook tNotebook)
			set source URL of cNote to bLoc
		end tell
	end repeat
	
	repeat with ynt in ynotes
		if separateFolders then set tNotebook to "Yojimbo Notes"
		(*	if doEncryptedNotes and ynt is encrypted then *)
		set bTitle to name of ynt
		set bMod to modification date of ynt
		set bCreate to creation date of ynt
		set nTags to tags of ynt
		set nProps to the properties of ynt
		set nBody to contents of nProps
		
		--body
		if nBody is missing value then set nBody to ""
		
		-- title
		if bTitle is missing value then set bTitle to ""
		if length of bTitle > maxTitleLength then
			set nBody to "Full title: " & bTitle & return & return & nBody
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of fTags
		if addTypeTags then copy "note" as string to the end of fTags
		log fTags
		
		tell application "Evernote"
			-- create note with text bTxt title bTitle created bCreate  notebook tNotebook
			create note with text nBody title bTitle created bCreate tags fTags notebook tNotebook
		end tell
		(*	end if *)
	end repeat
	
	repeat with ypwd in ypwds
		if separateFolders then set tNotebook to "Yojimbo Passwords"
		set bTitle to name of ypwd
		set bMod to modification date of ypwd
		set bCreate to creation date of ypwd
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
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set nBody to "Full title: " & bTitle & return & return & nBody
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of fTags
		if addTypeTags then copy "password" as string to the end of fTags
		
		tell application "Evernote"
			create note with text nBody title bTitle created bCreate tags fTags notebook tNotebook
		end tell
	end repeat
	
	repeat with ypdf in ypdfs
		if separateFolders then set tNotebook to "Yojimbo PDFs"
		set fname to "tmpdoc.pdf"
		set tmpFile to homeDir & fname
		set efile to (export ypdf to file tmpFile)
		set bTitle to name of ypdf
		set bMod to modification date of ypdf
		set bCreate to creation date of ypdf
		set ypdfTags to tags of ypdf
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set ptags to {}
		repeat with t in ypdfTags
			copy the name of t as string to the end of ptags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of ptags
		if addTypeTags then copy "pdf" as string to the end of ptags
		tell application "Evernote"
			create note from file efile title bTitle created bCreate notebook tNotebook tags ptags
		end tell
		-- delete the pdf
	end repeat
	
	repeat with yserial in yserials
		if separateFolders then set tNotebook to "Yojimbo Serial Numbers"
		set bTitle to name of yserial
		set bMod to modification date of yserial
		set bCreate to creation date of yserial
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
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set nBody to "Full title: " & bTitle & return & return & nBody
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of fTags
		if addTypeTags then copy "serial number" as string to the end of fTags
		
		tell application "Evernote"
			create note with text nBody title bTitle created bCreate tags fTags notebook tNotebook
		end tell
	end repeat
	
	repeat with yweb in ywebs
		if separateFolders then set tNotebook to "Yojimbo Web Archives"
		set bTitle to name of yweb
		set bMod to modification date of yweb
		set bCreate to creation date of yweb
		set nTags to tags of yweb
		set nProps to the properties of yweb
		set nSource to the source URL of yweb
		set nBody to the source URL of nProps
		
		-- title
		if bTitle is not missing value and length of bTitle > maxTitleLength then
			set bTitle to (get texts 1 through (maxTitleLength - 3) of bTitle) & "..."
		end if
		
		-- tags
		set fTags to {}
		repeat with tg in nTags
			copy the name of tg as string to the end of fTags
		end repeat
		if addYojimboTag then copy "Yojimbo" as string to the end of fTags
		if addTypeTags then copy "web archive" as string to the end of fTags
		
		tell application "Evernote"
			create note from url nSource title bTitle created bCreate tags fTags notebook tNotebook
		end tell

	end repeat

end tell

