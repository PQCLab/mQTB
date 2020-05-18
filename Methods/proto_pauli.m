function fun_proto = proto_pauli(nq)

proto = qtb_proto('pauli', nq);
proto.elems(1) = [];
fun_proto = static_proto(proto);

end

