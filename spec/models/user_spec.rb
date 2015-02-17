require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures :users

  before(:each) do
    @user = users(:waseem)
  end

  describe '#confirm' do
    it 'confirms the user' do
      @user.confirmed_at = nil
      @user.save
      expect(@user.confirmed_at).to be_nil
      @user.confirm
      expect(@user.confirmed_at).to be_present
    end
  end

  describe '#confirmed?' do
    context 'user is confirmed' do
      it 'is true' do
        expect(@user.confirmed?).to be_present
      end
    end

    context 'user is not confirmed' do
      it 'is false' do
        @user.confirmed_at = nil
        @user.save
        expect(@user.confirmed?).to be_blank
      end
    end
  end

  describe '#generate_token' do
    it 'assigns a unique token for specified column' do
      expect(@user).to(receive(:unique_token_for).with(:auth_token).and_return('new-auth-token'))
      expect(@user).to(receive(:[]=).with(:auth_token, 'new-auth-token').and_return('new-auth-token'))
      @user.generate_token(:auth_token)
    end
  end

  describe '#unique_token_for' do
    it 'generates a unique token for column' do
      auth_token = @user.auth_token
      expect(@user.unique_token_for(:auth_token)).to_not eq(auth_token)
    end
  end

  describe '#send_password_reset_email' do
    it 'sends password reset email' do
      mail = double()
      expect(@user).to(receive(:generate_token).with(:password_reset_token).and_return('password-reset-token'))
      expect(UserMailer).to(receive(:password_reset).with(@user.id).and_return(mail))
      expect(mail).to(receive(:deliver).with(no_args).and_return(true))
      @user.send_password_reset_email
    end
  end

  describe '#send_confirmation_email' do
    it 'sends confirmation email' do
      mail = double()
      expect(UserMailer).to(receive(:email_confirmation).with(@user.id).and_return(mail))
      expect(mail).to(receive(:deliver).with(no_args).and_return(true))
      @user.send_confirmation_email
    end
  end
end
