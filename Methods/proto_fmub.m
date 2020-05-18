function fun_proto = proto_fmub(dim)

elems = {1};
for j = 1:length(dim)
    proto = qtb_proto(['mub',num2str(dim(j))]);
    elems = qtb_tools.listkron(elems, proto.elems);
end
proto.elems = elems;
fun_proto = static_proto(proto);

end

