import React from 'react';

export const Footer: React.FC = () => {
    return (
        <footer className="bg-surface mt-12 py-6 border-t">
            <div className="container mx-auto text-center text-subtle">
                <p>&copy; {new Date().getFullYear()} Vending Machine Consumption Tracker. All rights reserved.</p>
            </div>
        </footer>
    );
}