# Preview all emails at http://localhost:3000/rails/mailers/hellotoken_mailer
class HellotokenMailerPreview < ActionMailer::Preview
	def test
		HellotokenMailer.test(Researcher.first)
	end

	def reconfirmation_instructions
		HellotokenMailer.confirmation_instructions(Researcher.first,"faketoken")
	end
end


