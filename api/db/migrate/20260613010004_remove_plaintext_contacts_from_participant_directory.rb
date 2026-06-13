class RemovePlaintextContactsFromParticipantDirectory < ActiveRecord::Migration[8.1]
  class DirectoryEntry < ActiveRecord::Base
    self.table_name = "participant_directory_entries"
  end

  def up
    add_column :participant_directory_entries, :email_masked, :string
    add_column :participant_directory_entries, :phone_masked, :string

    DirectoryEntry.reset_column_information
    DirectoryEntry.find_each do |entry|
      entry.update_columns(
        email_masked: mask_email(entry.email),
        phone_masked: mask_phone(entry.phone_e164 || entry.phone)
      )
    end

    remove_column :participant_directory_entries, :email, :string
    remove_column :participant_directory_entries, :phone, :string
    remove_column :participant_directory_entries, :phone_e164, :string
  end

  def down
    add_column :participant_directory_entries, :email, :string
    add_column :participant_directory_entries, :phone, :string
    add_column :participant_directory_entries, :phone_e164, :string
    remove_column :participant_directory_entries, :email_masked, :string
    remove_column :participant_directory_entries, :phone_masked, :string
  end

  private

  def mask_email(value)
    email = value.to_s.strip.downcase
    return nil if email.blank?

    local, domain = email.split("@", 2)
    return "[masked email]" if local.blank? || domain.blank?

    visible_local = local.length <= 2 ? "#{local.first}***" : "#{local.first(2)}***#{local.last}"
    "#{visible_local}@#{domain}"
  end

  def mask_phone(value)
    digits = value.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    "***-***-#{digits.last(4)}"
  end
end
