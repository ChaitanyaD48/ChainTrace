import{ Fot1, Fot2} from "../Components/index";

export default () => {
  const footernavs = [
    {
      href: "javascript:void()",
      name: "Terms",
    },
    {
      href: "javascript:void()",
      name: "License",
    },
    {
      href: "javascript:void()",
      name: "Privacy",
    },
    {
      href: "javascript:void()",
      name: "About Us",
    },
  ];
  return (
    <footer className="pt-10">
      <div className="max-w-screen-xl mx-auto px-4 text-gray-600 md:px-8">
        <div className="justify-between sm:flex">
          <div className="space-y-6">
            {/* <img src="https://www.floatui.com/logo.svg" className="w-32" /> */}
            <p className="max-w-md">
              Decentralised Supply Chain
            </p>
            <ul className="flex flex-wrap items-center gap-4 text-sm sm:text-base">
              {footernavs.map((item,idx) => (
                <li className="text-gray-800 hover:text-gray-500 duration-150">
                  <a key={idx} href={item.href}>
                    {item.name}
                  </a>
                </li> 
              ))}
            </ul>
          </div>
          <div className="mt-6">
            
            
          </div>
        </div>
        <div className="mt-10 py-10 border-t md:text-center">
          <p>@ChainTrace 2023</p>
        </div>
      </div>
    </footer>
  );
};