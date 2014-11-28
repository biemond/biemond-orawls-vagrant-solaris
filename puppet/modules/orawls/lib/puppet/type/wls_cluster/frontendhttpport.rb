newproperty(:frontendhttpport) do
  include EasyType
  include EasyType::Validators::Name

  desc 'The frontendhttpport of this cluster'

  to_translate_to_resource do | raw_resource|
    raw_resource['frontendhttpport']
  end

end
