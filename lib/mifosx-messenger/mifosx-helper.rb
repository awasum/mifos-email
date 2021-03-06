require 'open-uri'
require 'base64'
require 'net/http'
require 'json'

module MifosXMessenger
	class MifosXHelper

		@baseUrl = nil
		@http = nil
		@headers = nil

		def initialize(options = {})
			OpenSSL::SSL::VERIFY_PEER == OpenSSL::SSL::VERIFY_NONE
			@baseUrl = options['baseUrl'] || 'https://demo.openmf.org/fineract-provider-provider/api/v1'
			uri = URI.parse(@baseUrl)
			tenantId = options['tenantId'] || 'default'
			user = options['user'] || 'mifos'
			pass = options['pass'] || 'password'
			@http = Net::HTTP.new(uri.host, uri.port)
			@http.use_ssl = uri.scheme == 'https'
			@http.verify_mode = OpenSSL::SSL::VERIFY_PEER
			@headers = {
				'Fineract-Platform-TenantId' => tenantId,
				'Authorization' => 'Basic '+Base64.encode64(user+':'+pass).gsub("\n",'')
			}
		end

		def get_entity_uri(entity, entityId, prefUrl = @baseUrl)
			[prefUrl, entity, entityId.to_s].join('/')
		end

		def get_entity(path, options = {})
			path = URI.join(@baseUrl, path).path
			if fields = options[:fields]
				path += '?fields='+fields.join(',')
			end
			res = @http.request_get(path, @headers)
			if 'application/json' == res['content-type']
				return JSON.parse(res.body)
			end			
			return nil
		end

		def get_client(clientId, options = {})
			uri = get_entity_uri('clients', clientId)
			get_entity(uri, options)
		end
		def get_client_email(clientId)
			uri = get_entity_uri('email', clientId, 'https://localhost/fineract-provider/api/v1/datatables')
			get_entity(uri)
		end
		def get_loan(loanId, options = {})
			uri = get_entity_uri('loans', loanId)
			get_entity(uri, options)
		end

		def get_loan_transaction(loanId, transId, options = {})
			loan_uri = get_entity_uri('loans', loanId)
			uri = get_entity_uri('transactions', transId, loan_uri)
			get_entity(uri, options)
		end

		def get_savings(savingsId, options = {})
			uri = get_entity_uri('savingsaccounts', savingsId)
			get_entity(uri, options)
		end

		def get_savings_transaction(savingsId, transId, options = {})
			savings_uri = get_entity_uri('savingsaccounts', savingsId)
			uri = get_entity_uri('transactions', transId, savings_uri)
			get_entity(uri, options)
		end

		def get_fixed_deposit(fixedDepositId, transId, options = {})
			#fixed_deposit_uri = get_entity_uri('fixeddepositaccounts/template', fixedDepositId)
			uri = get_entity_uri('fixeddepositaccounts/template', fixedDepositId)
			get_entity(uri, options)
		end

		def get_fixed_deposit_transaction(fixedDepositId, transId, options = {})
			fixed_deposit_uri = get_entity_uri('fixeddepositaccounts/template', savingsId)
			uri = get_entity_uri('transactions', transId, fixed_deposit_uri)
			get_entity(uri, options)
		end

	end
end
