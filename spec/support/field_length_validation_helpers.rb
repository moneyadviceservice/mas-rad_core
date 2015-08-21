module FieldLengthValidationHelpers
  # USAGE: expect_length_of(subject, :field_name, 50).to be_valid
  def expect_length_of(subject, field, length, fill_char: 'x')
    num_chars_to_fill = (length - subject.send(field).length)
    new_value = subject.send(field) + (fill_char * num_chars_to_fill)
    subject.send("#{field}=", new_value)

    expect(subject)
  end
end
