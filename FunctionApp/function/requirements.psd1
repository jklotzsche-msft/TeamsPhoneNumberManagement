@{
	# Do you really need ALL of the AZ modules?
	# Az = '1.*'

	# If you only need Key Vault access, this is your choice
	# 'Az.KeyVault' = '4.*'

	# Basic tools used in your function app
	'Azure.Function.Tools'       = '1.*'

	# Needed to get token and login to Azure
	'Az.Accounts'                = '2.*'

	# TeamsPhoneNumberManagement module contains the functions to manage phone numbers in Teams and the TPNM database
	'TeamsPhoneNumberManagement' = '1.*'
}