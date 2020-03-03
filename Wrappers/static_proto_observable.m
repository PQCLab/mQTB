function measurement = static_proto_observable(j, n, proto, varargin)

measurement = static_proto(j, n, proto, varargin{:});
measurement.observable = measurement.povm;
measurement = rmfield(measurement,'povm');

end

