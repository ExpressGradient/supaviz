import config from "../supaviz.config";
import { Inter } from "@next/font/google";

const inter = Inter({ weight: ["400", "700"] });

export default function Header() {
    return (
        <header className={`m-4 lg:w-2/3 lg:mx-auto ${inter.className}`}>
            <h2 className="text-2xl font-bold">{config.projectName}</h2>
        </header>
    );
}
