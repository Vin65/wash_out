xml.instruct!
xml.tag! "soapenv:Envelope",  "xmlns:soapenv" => 'http://schemas.xmlsoap.org/soap/envelope/',
                              "xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema',
                              "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance' do
  if !header.nil?
    xml.tag! "soap:Header" do
      xml.tag! "tns:#{@action_spec[:response_tag]}" do
        wsdl_data xml, header
      end
    end
  end
  xml.tag! "soapenv:Body" do
    xml.tag! "ns1:#{@action_spec[:response_tag]}",  "soapenv:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/",
                                                    "xmlns:ns1" => @namespace,
                                                    "xmlns:tns" => @namespace  do
      wsdl_data xml, result
    end
  end
end
