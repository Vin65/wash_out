xml.instruct!
xml.tag! 'wsdl:definitions',
         'xmlns:apachesoap' => 'http://xml.apache.org/xml-soap',
         'xmlns:impl'       => @namespace,
         'xmlns:intf'       => @namespace,
         'xmlns:soapenc'    => 'http://schemas.xmlsoap.org/soap/encoding/',
         'xmlns:wsdl'       => 'http://schemas.xmlsoap.org/wsdl/',
         'xmlns:wsdlsoap'   => 'http://schemas.xmlsoap.org/wsdl/soap/',
         'xmlns:xsd'        => 'http://www.w3.org/2001/XMLSchema',
         'xmlns:xsi'        => 'http://www.w3.org/2001/XMLSchema-instance',
         'xmlns:tns'        => @namespace,
         'targetNamespace'  => @namespace do

  xml.tag! 'wsdl:types' do
    xml.tag! 'schema',
             :xmlns           => 'http://www.w3.org/2001/XMLSchema',
             :targetNamespace => @namespace do
      @map.each do |_operation, formats|
        (formats[:in] + formats[:out]).each do |p|
          wsdl_type xml, p
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml.tag! 'wsdl:message', :name => "#{operation}Request" do
      formats[:in].each do |p|
        xml.tag! 'wsdl:part', wsdl_occurence(p, true, :name => p.name, :type => p.namespaced_type)
      end
    end
    xml.tag! 'wsdl:message', :name => formats[:response_tag] do
      formats[:out].each do |p|
        xml.tag! 'wsdl:part', wsdl_occurence(p, true, :name => p.name, :type => p.namespaced_type)
      end
    end
  end

  xml.tag! 'wsdl:portType', :name => @service_name do
    @map.each do |operation, formats|
      xml.tag! 'wsdl:operation',
               :name            => operation,
               :parameterOrder  => 'Request' do
        xml.tag! 'wsdl:input',
                 :message       => "impl:#{operation}Request",
                 :name          => "#{operation}Request"
        xml.tag! 'wsdl:output',
                 :message       => "impl:#{formats[:response_tag]}",
                 :name          => formats[:response_tag]
      end
    end
  end

  xml.tag! 'wsdl:binding',
           :name        => "#{@service_name}.cfcSoapBinding",
           :type        => "impl:#{@service_name}" do
    xml.tag! 'wsdlsoap:binding',
             :style     => 'rpc',
             :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.each do |operation, formats|
      xml.tag! 'wsdl:operation', :name => operation do
        xml.tag! 'wsdlsoap:operation', :soapAction => ''
        xml.tag! 'wsdl:input', :name => "#{operation}Request" do
          xml.tag! 'wsdlsoap:body',
                   :use           => 'encoded',
                   :encodingStyle => 'http://schemas.xmlsoap.org/soap/encoding/',
                   :namespace     => @namespace
        end
        xml.tag! 'wsdl:output', :name => formats[:response_tag] do
          xml.tag! 'wsdlsoap:body',
                   :use           => 'encoded',
                   :encodingStyle => 'http://schemas.xmlsoap.org/soap/encoding/',
                   :namespace     => @namespace
        end
      end
    end
  end

  xml.tag! 'wsdl:service', :name => @service_name do
    xml.tag! 'wsdl:port',
             :name    => "#{@service_name}.cfc",
             :binding => "impl:#{@service_name}.cfcSoapBinding" do
      xml.tag! 'wsdlsoap:address', :location => @location
    end
  end
end
